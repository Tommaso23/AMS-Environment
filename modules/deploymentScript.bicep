param location string
param deploymentScriptName string
param storageAccountName string
param storageAccountId string

param functionAppStorageAccountName string
param functionAppStorageAccountId string

param blobContainerName string
param fileShareName string
param storageAccountApiVersion string
param currentTime string = utcNow('u')

var sasDefinition = {
  signedServices: 'b'
  signedPermission: 'rwdlacup'
  signedExpiry: dateTimeAdd(currentTime, 'PT1H')
  signedResourceTypes: 'sco'
  signedProtocol: 'https'
  keyTosign: 'key1'
}
var fileSasDefinition = {
  signedServices: 'f'
  signedPermission: 'rwdlacup'
  signedExpiry: dateTimeAdd(currentTime, 'PT1H')
  signedResourceTypes: 'sco'
  signedProtocol: 'https'
  keyTosign: 'key1'
}

var functionAppSasToken = listAccountSas(functionAppStorageAccountId, storageAccountApiVersion, sasDefinition).accountSasToken
var sasToken = listAccountSas(storageAccountId, storageAccountApiVersion,fileSasDefinition).accountSasToken

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    scriptContent: 'wget https://github.com/Tommaso23/Azure-Media-Services-environment/raw/master/code/functionApp.zip -O functionApp.zip  && az storage blob upload --account-name ${functionAppStorageAccountName} --sas-token "${functionAppSasToken}" --container-name ${blobContainerName} --name functionApp.zip --type block --file functionApp.zip --overwrite true && wget https://github.com/Tommaso23/Azure-Media-Services-environment/raw/master/code/ffmpegscript.sh -O ffmpegscript.sh && az storage file upload --account-name ${storageAccountName} --sas-token "${sasToken}" --share-name ${fileShareName} --source ffmpegscript.sh && wget https://github.com/Tommaso23/Azure-Media-Services-environment/raw/master/code/webApp.zip -O webApp.zip && az storage blob upload --account-name ${functionAppStorageAccountName} --sas-token "${functionAppSasToken}" --container-name ${blobContainerName} --name webApp.zip --type block --file webApp.zip --overwrite true' 
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output functionReleaseBlobUrl string = 'https://${functionAppStorageAccountName}.blob.core.windows.net/${blobContainerName}/functionApp.zip'
output webAppReleaseBlobUrl string = 'https://${functionAppStorageAccountName}.blob.core.windows.net/${blobContainerName}/webApp.zip'
