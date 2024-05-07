param location string
param storageAccountName string
param blobContainerName string
param storageAccountId string
param storageAccountApiVersion string
var userAssignedIdentityName = 'configDeployer'
var roleAssignmentName = guid(resourceGroup().id, 'contributor')

var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

var sasDefinition = {
  signedServices: 'b'
  signedPermission: 'rwdlacup'
  signedExpiry: '2024-05-7T00:00:00Z'
  signedResourceTypes: 'sco'
  signedProtocol: 'https'
  keyTosign: 'key1'
}

var sasToken = listAccountSas(storageAccountId, storageAccountApiVersion, sasDefinition).accountSasToken


resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: userAssignedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedIdentity.properties.principalId
    //principalId: reference(userAssignedIdentity.id, '2018-11-30').principalId
    //scope: resourceGroup().id
    //principalType: 'ServicePrincipal'
    
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'uploadFile'
  location: location
  kind: 'AzureCLI'
  /*identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }*/
  properties: {
    azCliVersion: '2.52.0'
    scriptContent: 'wget https://github.com/Tommaso23/Azure-Media-Services-environment/blob/master/code/functionApp.zip -O functions.zip  && az storage blob upload --account-name ${storageAccountName} --sas-token ${sasToken} --container-name ${blobContainerName} --name functionsCode --type block --file functions.zip'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
