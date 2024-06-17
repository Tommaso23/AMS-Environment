var location = resourceGroup().location
var uniqueId = take(uniqueString(subscription().subscriptionId, resourceGroup().id), 7)
var storageAccountName = 'stmediaservices${uniqueId}'
var functionAppStorageAccountName = 'stmediaservicesfa${uniqueId}'
var cosmosdbaccountName = 'cosmos-mediaservices-${uniqueId}'
var cosmosdbsqldatabaseName = 'cossql-mediaservices-${uniqueId}'
var cdnProfileName = 'cdn-mediaservices-${uniqueId}'
var cdnEndpointName = 'cdne-mediaservices-${uniqueId}'
var functionappName = 'func-mediaservices-${uniqueId}'
var webAppName = 'wa-mediaservices-${uniqueId}'
var logAnalyticsWorkspaceName = 'log-mediaservices-${uniqueId}'
var functionappAppServicePlanName = 'asp-mediaservices-${uniqueId}'
var applicationInsightsName = 'appi-mediaservices-${uniqueId}'
var deploymentScriptName = 'depfunczip-mediaservices-${uniqueId}'
var fileShareName = 'assets-share'
var scriptShareName = 'script-share'
var queueName = 'encoderjobs-queue'
var blobServiceName = 'default'
var blobContainerName = 'assets-storage-container'
var functionAppBlobContainerName = 'code-storage-container'
var sqlcontainerJobsName = 'EncoderJobs'
var sqlcontainerPresetsName = 'EncoderPresets'
var containerInstanceName = 'ci-mediaservices-${uniqueId}'
var loadPresetDeploymentScriptName = 'loadpredep-mediaservices-${uniqueId}'
var webAppSettings = [
  {
    name: 'ENCODER_ASSETS_STORAGE_CONTAINER_NAME'
    value: blobContainerName 
  }
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID'
    value: deploymentScript.outputs.webAppReleaseBlobUrl
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'Recommended'
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'FUNCTIONAPP_API_URL'
    value: 'https://${toLower(functionappName)}.azurewebsites.net'
  }
  {
    name: 'WEBSITE_ENCODERASSETSSTORAGECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.outputs.storageAccountKey};EndpointSuffix=core.windows.net'
  }
]
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
    value: cosmosdbsqldatabaseName
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
    value: functionAppStorageAccountName

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
    name: 'STORAGE_ACCOUNT_NAME'
    value: storageAccountName
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
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: deploymentScript.outputs.functionReleaseBlobUrl
  }
  {
    name: 'CONTAINER_INSTANCE_NAME'
    value: containerInstanceName
  }
]
var storageBlobReaderRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// create storage account for media assets
module storageAccount 'modules/storageaccount.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName
    isPublicAccessible: true
  }
}

//create storage account for function app
module functionAppStorageAccount 'modules/storageaccount.bicep'= {
  name: 'functionAppStorageAccount'
  params: {
    location: location
    storageAccountName: functionAppStorageAccountName
    isPublicAccessible: true //TODO: Modify it to False
  }
}

// create blob container for functionApp.zip
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

// create ddeployment script
module deploymentScript 'modules/deploymentScript.bicep' = {
  name: 'deploymentScript'
  params: {
    location: location
    deploymentScriptName: deploymentScriptName
    storageAccountName: storageAccountName
    functionAppStorageAccountName: functionAppStorageAccountName
    fileShareName: scriptShareName
    storageAccountId: storageAccount.outputs.storageAccountId
    functionAppStorageAccountId: functionAppStorageAccount.outputs.storageAccountId
    storageAccountApiVersion: functionAppStorageAccount.outputs.storageAccountApiVersion
    blobContainerName: functionAppBlobContainerName
  }
  dependsOn: [
    functionAppBlobContainer
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

module blobService 'modules/blobServices.bicep' = {
  name: 'blobService'
  params: {
    blobServiceName: blobServiceName
    storageAccountName: storageAccountName
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

//create web app
module webApp 'modules/webApp.bicep' = {
  name: 'webApp'
  params: {
    location: location
    webAppName: webAppName
    serverFarmId: functionappAppServicePlanName
    webAppSettings: webAppSettings
  }
  dependsOn: [
    deploymentScript
  ]
}

//assign storage blob reader to functionApp
module functionStorageRoleAssignment 'modules/roleassignment.bicep' = {
  name: 'functionStorageRoleAssignment'
  params: {
    roleDefinitionId: storageBlobReaderRoleDefinitionId
    principalId: functionApp.outputs.principalId
  }
  dependsOn: [
    functionApp
    deploymentScript
  ]
}

//assign contributor role to functionApp
module functionContainerRoleAssignment 'modules/roleassignment.bicep' = {
  name: 'functionContainerRoleAssignment'
  params: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: functionApp.outputs.principalId
  }
}

//assign contributor role to webApp
module webappContainerRoleAssignment 'modules/roleassignment.bicep' = {
  name: 'webappContainerRoleAssignment'
  params: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: webApp.outputs.principalId
  }
}



//create app service plan
module appServicePlan 'modules/appServicePlan.bicep' = {
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
module cdnEndpoint 'modules/cdnendpoint.bicep' = {
  name: 'cdnEndpoint'
  params: {
    cdnProfileName: cdnProfileName
    cdnEndpointName: cdnEndpointName
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

module sqlroleAssignment 'modules/sqlRoleAssignment.bicep' = {
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
    workspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}


module loadPresetDeploymentScript 'modules/loadPresetdeploymentScript.bicep' = {
  name: 'loadPresetDeploymentScript'
  params: {
    deploymentScriptName: loadPresetDeploymentScriptName
    location: location
    functionAppName: functionappName
  }
  dependsOn: [
    functionApp
  ]
}
