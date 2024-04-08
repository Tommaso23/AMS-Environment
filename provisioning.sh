#!/bin/bash

# provisioning parameters

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Please download and install it from the following links:"
    echo "For Windows: https://aka.ms/installazurecliwindows"
    echo "For macOS: https://aka.ms/installazurecliosx"
    echo "For Linux: https://aka.ms/installazureclilinux"
    exit 1
fi

# check if the jq tool is installed otherwise provide the link to download it
if ! command -v jq &> /dev/null; then
    echo "jq tool is not installed. Please download and install it from the following links:"
    echo "For Windows: https://stedolan.github.io/jq/download/"
    echo "For macOS: https://stedolan.github.io/jq/download/"
    echo "For Linux: https://stedolan.github.io/jq/download/"
    exit 1
fi

subscription_id="edbb133d-8dcb-44c9-8fd2-03e32cb9025e"
tenant_id="db562c58-fcbc-475f-8a5d-13a2ea26a57f"

# check if azure cli is already signed in
if ! az account show &> /dev/null; then
    # proceed to login
    az login --tenant $tenant_id
fi

# set subscription
az account set --subscription $subscription_id

resource_group="grp-mcencoder"
location="germanywestcentral"
storage_account_name="mcencoderassetssa"
fa_storage_account_name="mcencfasa"
assets_file_share_name="assets-share"
scripts_file_share_name="scripts-share"
blob_container_name="blob-storage-container"
function_app_name="mc-encoder-fa-api"
function_app_runtime="dotnet"
cosmos_db_account_name="mc-encoder-cosmos-account"
sql_database_name="mc-encoder-db"
encoder_jobs_queue_name="encoderjobs-queue"

# create resource group
if az group exists --name $resource_group &> /dev/null; then
    echo "Resource group already exists."
else
    az group create --name $resource_group --location $location
fi

# create storage account for media assets
if az storage account show --name $storage_account_name --resource-group $resource_group &> /dev/null; then
    echo "Storage account already exists."
else
    az storage account create --name $storage_account_name --resource-group $resource_group --location $location --sku Standard_LRS
fi


# create storage account for function app
if az storage account show --name $fa_storage_account_name --resource-group $resource_group &> /dev/null; then
    echo "Storage account already exists."
else
    az storage account create --name $fa_storage_account_name --resource-group $resource_group --location $location --sku Standard_LRS
fi

fa_storage_account_key=$(az storage account keys list --account-name $fa_storage_account_name --resource-group $resource_group --query "[0].value" --output tsv)

# create queue
if az storage queue exists --name $encoder_jobs_queue_name --account-name $fa_storage_account_name --account-key $fa_storage_account_key --only-show-errors --output json | jq -r '.exists' | grep -q "false"; then
    az storage queue create --name $encoder_jobs_queue_name --account-name $fa_storage_account_name --account-key $fa_storage_account_key
else
    echo "Queue already exists."
fi

# retrieve storage account key
storage_account_key=$(az storage account keys list --account-name $storage_account_name --resource-group $resource_group --query "[0].value" --output tsv)

# create file shares
if az storage share exists --name $assets_file_share_name --account-name $storage_account_name --account-key $storage_account_key --only-show-errors --output json | jq -r '.exists' | grep -q "false"; then
    az storage share create --name $assets_file_share_name --account-name $storage_account_name --account-key $storage_account_key
else
    echo "Assets file share already exists."
fi

if az storage share exists --name $scripts_file_share_name --account-name $storage_account_name --account-key $storage_account_key --only-show-errors --output json | jq -r '.exists' | grep -q "false"; then
    az storage share create --name $scripts_file_share_name --account-name $storage_account_name --account-key $storage_account_key
else
    echo "Scripts file share already exists."
fi

# create blob storage
if az storage container exists --name $blob_container_name --account-name $storage_account_name --account-key $storage_account_key --only-show-errors --output json | jq -r '.exists' | grep -q "false"; then
    az storage container create --name $blob_container_name --account-name $storage_account_name --auth-mode login
else
    echo "blob storage already exists."
fi


# check if function app already exists
if az functionapp show --name $function_app_name --resource-group $resource_group &> /dev/null; then
    echo "Function app already exists."
else
    # create function app with system-assigned managed identity
    az functionapp create --name $function_app_name \
    --resource-group $resource_group \
    --storage-account $fa_storage_account_name \
    --runtime $function_app_runtime \
    --os-type Linux \
    --functions-version 4 \
    --consumption-plan-location $location \
    --assign-identity [system]
    
    # retrieve function app identity
    function_app_identity=$(az functionapp identity show --name $function_app_name --resource-group $resource_group --query principalId --output tsv)
    
    # assign storage account reader role to function app identity
    az role assignment create --role "Storage Blob Data Contributor" --assignee $function_app_identity --scope "/subscriptions/"$subscription_id"/resourceGroups/"$resource_group"/providers/Microsoft.Storage/storageAccounts/"$fa_storage_account_name
    # assign reader and writer to queue
    az role assignment create --role "Storage Queue Data Contributor" --assignee $function_app_identity --scope "/subscriptions/"$subscription_id"/resourceGroups/"$resource_group"/providers/Microsoft.Storage/storageAccounts/"$fa_storage_account_name"/queueServices/default/queues/"$encoder_jobs_queue_name
    
    # TODO: add permissions
    # az role assignment create --role "Contributor" --assignee $function_app_identity --scope "/subscriptions/"$subscription_id"/resourceGroups/"$resource_group
fi

cosmos_custom_role_defid=""
# create a new cosmos db account
# check if Cosmos DB account already exists
if az cosmosdb show --name $cosmos_db_account_name --resource-group $resource_group &> /dev/null; then
    echo "Cosmos DB account already exists."
else
    az cosmosdb create --name $cosmos_db_account_name --resource-group $resource_group --kind GlobalDocumentDB --locations regionName=$location failoverPriority=0 isZoneRedundant=False
    
    cosmos_custom_role_defid=$(az cosmosdb sql role definition create --account-name $cosmos_db_account_name \
    --resource-group $resource_group --body @cosmos-db-role-definition.json --query id --output tsv)
    
    if (cosmos_custom_role_defid != "") then
        az cosmosdb sql role assignment create \
        --account-name $cosmos_db_account_name \
        --resource-group $resource_group \
        --principal-id $function_app_identity \
        --scope "/" \
        --role-definition-id $cosmos_custom_role_defid
    fi
fi

# create a new SQL database
# check if database already exists
if az cosmosdb sql database show --account-name $cosmos_db_account_name --resource-group $resource_group --name $sql_database_name &> /dev/null; then
    echo "Database already exists."
else
    # create a new SQL database
    az cosmosdb sql database create --account-name $cosmos_db_account_name --resource-group $resource_group --name $sql_database_name
fi

function_app_identity=$(az functionapp identity show --name $function_app_name --resource-group $resource_group --query principalId --output tsv)

#create a new SQL Container for EncoderJobs
# check if container already exists
if az cosmosdb sql container show --account-name $cosmos_db_account_name --resource-group $resource_group --database-name $sql_database_name --name EncoderJobs &> /dev/null; then
    echo "Container Encoder Jobs already exists."
else
    # create a new SQL container for EncoderJobs
    az cosmosdb sql container create \
    --account-name $cosmos_db_account_name \
    --resource-group $resource_group \
    --database-name $sql_database_name \
    --name EncoderJobs \
    --partition-key-path /id \
    --throughput 400

    az cosmosdb sql role assignment create \
    --account-name $cosmos_db_account_name \
    --resource-group $resource_group \
    --principal-id $function_app_identity \
    --scope /dbs/$sql_database_name/colls/EncoderJobs \
    --role "Cosmos DB Built-in Data Contributor"
fi
    az cosmosdb sql role assignment create \
    --account-name $cosmos_db_account_name \
    --resource-group $resource_group \
    --principal-id $function_app_identity \
    --scope /dbs/$sql_database_name/colls/EncoderJobs \
    --role-definition-name "Cosmos DB Built-in Data Contributor"


# check if container already exists
if az cosmosdb sql container show --account-name $cosmos_db_account_name --resource-group $resource_group --database-name $sql_database_name --name EncoderPresets &> /dev/null; then
    echo "Container EncoderPresets already exists."
else
    # create a new SQL container for EncoderPresets
    az cosmosdb sql container create \
    --account-name $cosmos_db_account_name \
    --resource-group $resource_group \
    --database-name $sql_database_name \
    --name EncoderPresets \
    --partition-key-path /id \
    --throughput 400

    az cosmosdb sql role assignment create \
    --account-name $cosmos_db_account_name \
    --resource-group $resource_group \
    --principal-id $function_app_identity \
    --scope /dbs/$sql_database_name/colls/EncoderPresets \
    --role-definition-name "Cosmos DB Built-in Data Contributor"
fi

# Get Cosmos DB endpoint
as_cosmos_db_endpoint=$(az cosmosdb show --name $cosmos_db_account_name --resource-group $resource_group --query documentEndpoint --output tsv)
as_cosmos_db_account_key=$(az cosmosdb keys list --name $cosmos_db_account_name --resource-group $resource_group --query primaryMasterKey --output tsv)

az functionapp config appsettings set \
--name $function_app_name \
--resource-group $resource_group \
--settings "COSMOS_DB_ENDPOINT="$as_cosmos_db_endpoint "COSMOS_DB_DATABASE="$cosmos_db_account_name "COSMOS_DB_ENCODERJOBS_CONTAINER=EncoderJobs" "COSMOS_DB_ENCODERPRESETS_CONTAINER=EncoderPresets" "COSMOS_DB_CONTAINER_TEST=TestRecords" "COSMOS_DB_AUTH_KEY="$as_cosmos_db_account_key "FA_STORAGE_ACCOUNT_NAME="$fa_storage_account_name "FA_STORAGE_ENCODERJOBS_QUEUE_NAME="$encoder_jobs_queue_name

#TODO: add settings 
#"SUBSCRIPTION_ID="$subscription_id
#"TENANT_ID="$tenant_id
#"STORAGE_ACCOUNT_KEY="$storage_account_key
#"ENCODERASSETS_CONNECTIONSTRING="$

