param location string
param storageAccountName string
param blobContainerName string
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
  name: 'uploadFile'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    scriptContent: 'wget https://github.com/Tommaso23/Azure-Media-Services-environment/blob/master/code/functionApp.zip -O functionApp.zip  && az storage blob upload --account-name ${storageAccountName} --sas-token "${sasToken}" --container-name ${blobContainerName} --name functionApp.zip --type block --file functionApp.zip'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
