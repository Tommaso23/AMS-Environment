param location string = 'germanywestcentral'
param storageAccountName string = 'stmediaservices001'
param functionAppStorageAccountName string = 'stmediaservicesfuncapp01'
param fileShareName string = 'assets-share'
param scriptShareName string = 'script-share'
param blobContainerName string = 'assets-storage-container'
param functionAppBlobContainerName string = 'code-storage-container'
param queueName string = 'functionapp-queue'
param cosmosdbaccountName string = 'cosmos-mediaservices'
param cosmosdbsqldatabaseName string = 'sqldb-mediaservices'
param sqlcontainerJobsName string = 'EncoderJobs'
param sqlcontainerPresetsName string = 'EncoderPresets'
param cdnProfileName string = 'cdn-mediaservices'
param privateEndpointName string = 'pe-cdn-mediaservices'
param functionappName string = 'fa-mediaservices'
param functionappAppServicePlanName string = 'functionapp-plan-mediaservices'
param logAnalyticsWorkspaceName string = 'logAnalytics-mediaservices'
param applicationInsightsName string = 'applicationInsights-mediaservices'
//'C:\Users\t-tbucaioni\Desktop\tom-encoder.zip'
/*
param vaults_vault138_name string = 'vault138'
param serverfarms_GermanyWestCentralLinuxDynamicPlan_name string = 'GermanyWestCentralLinuxDynamicPlan'
param actionGroups_Application_Insights_Smart_Detection_name string = 'Application Insights Smart Detection'
param smartdetectoralertrules_failure_anomalies_tom_encoder_fa_api_name string = 'failure anomalies - tom-encoder-fa-api'
param workspaces_DefaultWorkspace_d0bdc55f_fe1e_4172_96a6_6b55f5dd28ff_DEWC_externalid string = '/subscriptions/d0bdc55f-fe1e-4172-96a6-6b55f5dd28ff/resourceGroups/DefaultResourceGroup-DEWC/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-d0bdc55f-fe1e-4172-96a6-6b55f5dd28ff-DEWC'
*/

var appSettings = [

  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppStorageAccountName};AccountKey=${functionAppStorageAccount.outputs.storageAccountKey}'
  }
  {
    name: 'COSMOS_DB_AUTH_KEY'
    value: cosmosdbaccount.outputs.cosmosdbauthentificationKey
  }
  {
    name: 'COSMOS_DB_DATABASE'
    value: cosmosdbaccountName
  }
  {
    name: 'COSMOS_DB_ENCODERJOBS_CONTAINER'
    value: sqlcontainerJobsName
  }
  {
    name: 'COSMOS_DB_PRESETS_CONTAINER'
    value: sqlcontainerPresetsName
  }
  {
    name: 'COSMOS_DB_ENDPOINT'
    value: cosmosdbaccount.outputs.cosmosdbendpoint
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  
  {
    name: 'ENCODER_ASSETS_STORAGE_CONTAINER_NAME'
    value: blobContainerName
  }
  {
    name: 'ENCODER_ASSETS_STORAGE_FILESHARE_NAME'
    value: fileShareName
  }
  {
    name: 'FA_STORAGE_ACCOUNT_NAME'
    value: functionappName
  }
  {
    name: 'FA_STORAGE_ENCODERJOBS_QUEUE_NAME'
    value: queueName
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet-isolated'
  }
  {
    name: 'RESOURCE_GROUP_NAME'
    value: resourceGroup().name
  }
  {
    name: 'STORAGE_ACCOUNT_KEY'
    value: storageAccount.outputs.storageAccountKey
  }
  {
    name: 'SUBSCRIPTION_ID'
    value: subscription().subscriptionId
  }
  {
    name: 'TENANT_ID'
    value: tenant().tenantId
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=${functionAppStorageAccountName};AccountKey=${functionAppStorageAccount.outputs.storageAccountKey}'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: toLower(functionappName)
  }
  {
    name: 'WEBSITE_ENCODERASSETSSTORAGECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.outputs.storageAccountKey};EndpointSuffix=core.windows.net'
  }
  {
    name: 'WEBSITE_MOUNT_ENABLED'
    value: '1'
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: 'InstrumentationKey=${applicationInsights.outputs.instrumentationKey}'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: applicationInsights.outputs.instrumentationKey
  }
  
  /*{
    //name: 'WEBSITE_RUN_FROM_PACKAGE'
    //value: 'https://tomencfasa.blob.core.windows.net/function-releases/20240327102907-08f88fcf7b2b91dcbc05dac9046e2eb1.zip?sv=2022-11-02&st=2024-03-27T10%3A24%3A35Z&se=2034-03-27T10%3A29%3A35Z&sr=b&sp=r&sig=9yCWOIf9pR7dS1IZGtlMqKppsNh6h7CkU9m8G5GYYfc%3D'
  }
*/
]
var storageBlobReaderRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')

// create storage account for media assets
module storageAccount 'modules/storageaccount.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

//create storage account for function app
module functionAppStorageAccount 'modules/storageaccount.bicep'= {
  name: 'functionAppStorageAccount'
  params: {
    location: location
    storageAccountName: functionAppStorageAccountName
  }
}

module functionAppBlobContainer 'modules/blobcontainer.bicep' = {
  name: 'functionAppBlobContainer'
  params: {
    storageAccountName: functionAppStorageAccountName
    blobContainerName: functionAppBlobContainerName
  }
  dependsOn: [
    functionAppStorageAccount
  ]

}

//create queue
module queue 'modules/queue.bicep' = {
  name: 'queue'
  params: {
    storageAccountName: functionAppStorageAccountName
    queueName: queueName
  }
  dependsOn: [
    functionAppStorageAccount
  ]
}

module deploymentScript 'modules/deploymentScript.bicep' = {
  name: 'deploymentScript'
  params: {
    location: location
    storageAccountName: functionAppStorageAccountName
    storageAccountId: functionAppStorageAccount.outputs.storageAccountId
    storageAccountApiVersion: functionAppStorageAccount.outputs.storageAccountApiVersion
    blobContainerName: blobContainerName
  }
  dependsOn: [
    functionAppStorageAccount
  ]
}

// create file share
module fileShare 'modules/fileshare.bicep' = {
  name: 'fileShare'
  params: {
    storageAccountName: storageAccountName
    fileShareName: fileShareName
  }
  dependsOn: [
    storageAccount
  ]
}

// create script share
module scriptFileShare 'modules/fileshare.bicep' = {
  name: 'ScriptFileShare'
  params: {
    storageAccountName: storageAccountName
    fileShareName: scriptShareName
  }
  dependsOn: [
    storageAccount
  ] 
}

// create blob storage
module blobContainer 'modules/blobcontainer.bicep' = {
  name: 'blobContainer'
  params: {
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
  }
  dependsOn: [
    storageAccount
  ]
}

// create function app
module functionApp 'modules/functionapp.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    functionAppName: functionappName
    serverFarmId: functionappAppServicePlanName
    appSettings: appSettings
  }
  dependsOn: [
    deploymentScript
  ]
}

module functionRoleAssignment 'modules/roleassignment.bicep' = {
  name: 'functionRoleAssignment'
  params: {
    roleDefinitionId: storageBlobReaderRoleDefinitionId
    principalId: functionApp.outputs.principalId
  }
  dependsOn: [
    functionApp
    deploymentScript
  ]
}

//create app service plan
module appServicePlan 'modules/appserviceplan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    functionappAppServicePlanName: functionappAppServicePlanName
  }
}

// create cosmos DB
module cosmosdbaccount 'modules/cosmosdbaccount.bicep' = {
  name: 'cosmosdbaccount'
  params: {
    location: location
    cosmosDBAccountName: cosmosdbaccountName
  }

}

// create cosmos DB SQL database
module cosmosdbsqldatabase 'modules/cosmosdbsqldatabase.bicep' = {
  name: 'cosmosDBSQLDatabase'
  params: {
    cosmosdbaccountName: cosmosdbaccountName
    cosmosdbsqlDatabaseName: cosmosdbsqldatabaseName
    //cosmosdbaccountNameId: cosmosdbaccount.outputs.cosmosdbaccountId
  }
  dependsOn: [
    cosmosdbaccount
  ]
}

// create cosmos DB SQL container for EncoderJobs
module sqlcontainerJobs 'modules/sqlcontainer.bicep' = {
  name: 'sqlcontainerJobs'
  params: {
    cosmosdbAccountName: cosmosdbaccountName
    sqldbName: cosmosdbsqldatabaseName
    sqlcontainerName: sqlcontainerJobsName
  }
  dependsOn: [
    cosmosdbsqldatabase
  ]
}

// create cosmos DB SQL container for EncoderPresets
module sqlcontainerPresets 'modules/sqlcontainer.bicep' = {
  name: 'sqlcontainerPresets'
  params: {
    cosmosdbAccountName: cosmosdbaccountName
    sqldbName: cosmosdbsqldatabaseName
    sqlcontainerName: sqlcontainerPresetsName
  }
  dependsOn: [
    cosmosdbsqldatabase
  ]
}

// create CDN profile
module cdn 'modules/cdn.bicep' = {
  name: 'cdn'
  params: {
    cdnProfileName: cdnProfileName
  }
}

// create private endpoint for CDN
module privateEndpoint 'modules/privateendpoint.bicep' = {
  name: 'privateEndpoint'
  params: {
    cdnProfileName: cdnProfileName
    privateEndpointName: privateEndpointName
    originHostName: storageAccount.outputs.blobEndpoint
  }
}

module sqlRoleDefinition 'modules/sqlRoleDefinition.bicep' = {
  name: 'sqlRoleDefinition'
  params: {
    cosmosdbAccountName: cosmosdbaccountName
    cosmosdbAccountId: cosmosdbaccount.outputs.cosmosdbaccountId
  }
}

module sqlroleAssignment 'modules/sqlroleAssignment.bicep' = {
  name: 'sqlroleAssignment'
  params: {
    cosmosDBAccountName: cosmosdbaccountName
    cosmosDBAccountId: cosmosdbaccount.outputs.cosmosdbaccountId
    principalId: functionApp.outputs.principalId
    roleDefinitionId: sqlRoleDefinition.outputs.roleDefinitionId
  }
  dependsOn: [
    sqlRoleDefinition
  ]
}

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    location: location
    applicationInsightsName: applicationInsightsName
    workspaceId: logAnalytics.outputs.logAnlayticsWorkspaceId
  }
}

/*resource profiles_cdn_profile_tom_encoder_name_cdn_endpoint_tom_encoder_default_origin_fa96716a 'Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview' = {
  parent: profiles_cdn_profile_tom_encoder_name_cdn_endpoint_tom_encoder
  name: 'default-origin-fa96716a'
  properties: {
    hostName: 'tomencoderassetssa.blob.core.windows.net' //parametrizzare con nome storage account blob
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'tomencoderassetssa.blob.core.windows.net'
    priority: 1
    weight: 1000
    enabled: true
  }
  dependsOn: [
    profiles_cdn_profile_tom_encoder_name_resource
  ]
}*/



/*resource sites_tom_encoder_fa_api_name_web 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: sites_tom_encoder_fa_api_name_resource
  name: 'web'
  location: location
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOTNET-ISOLATED|8.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$tom-encoder-fa-api'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 13208
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}*/



/*resource databaseAccounts_tom_encoder_cosmos_account_name_1ef2606b_b668_42d2_949a_ffa13987a08b 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: '1ef2606b-b668-42d2-949a-ffa13987a08b'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6e8a2b9b-cf63-426b-b944-b5611c268c45'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderJobs'
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_537302ef_f6a3_44de_a5e8_63151e300573 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: '537302ef-f6a3-44de-a5e8-63151e300573'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_1d60ffaf_3404_4448_b688_dd8a441e5f1a.id
    principalId: '6d2dbc11-ecf1-4709-b4be-af198550f7bf'
    scope: databaseAccounts_tom_encoder_cosmos_account_name_resource.id
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_c6065151_ba39_46d2_8098_173d1d1172f0 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'c6065151-ba39-46d2-8098-173d1d1172f0'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6d2dbc11-ecf1-4709-b4be-af198550f7bf'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderPresets'
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_d4988ed0_7ab7_4da3_afb8_99015e6f8d57 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'd4988ed0-7ab7-4da3-afb8-99015e6f8d57'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6d2dbc11-ecf1-4709-b4be-af198550f7bf'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderJobs'
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_e21b5273_947d_4561_8ccb_7112a6d27dd5 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'e21b5273-947d-4561-8ccb-7112a6d27dd5'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6e8a2b9b-cf63-426b-b944-b5611c268c45'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderPresets'
  }
}*/







