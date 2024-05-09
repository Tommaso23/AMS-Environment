param location string
param deploymentScriptName string
param storageAccountName string
param functionAppStorageAccountName string
param blobContainerName string
param fileShareName string
param storageAccountId string
param storageAccountApiVersion string = '2023-05-01'
param currentTime string = utcNow('u')

var sasDefinition = {
  signedServices: 'b'
  signedPermission: 'rwdlacup'
  signedExpiry: dateTimeAdd(currentTime, 'PT1H')
  signedResourceTypes: 'sco'
  signedProtocol: 'https'
  keyTosign: 'key1'
}

var sasToken = listAccountSas(storageAccountId, storageAccountApiVersion, sasDefinition).accountSasToken

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    scriptContent: 'wget https://github.com/Tommaso23/Azure-Media-Services-environment/raw/master/code/functionApp.zip -O functionApp.zip  && az storage blob upload --account-name ${functionAppStorageAccountName} --sas-token "${sasToken}" --container-name ${blobContainerName} --name functionApp.zip --type block --file functionApp.zip --overwrite true && wget https://github.com/Tommaso23/Azure-Media-Services-environment/raw/master/code/ffmpegscript.sh -O ffmpegscript.sh && az storage file upload --account-name ${storageAccountName} --sas-token "${sasToken}" --share-name ${fileShareName} --source ffmpegscript.sh --name ffmpegscript.sh ' 
    
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output blobUrl string = 'https://${storageAccountName}.blob.core.windows.net/${blobContainerName}/functionApp.zip'
