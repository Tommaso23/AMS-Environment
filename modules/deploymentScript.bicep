param location string
param storageAccountName string
param blobContainerName string
var userAssignedIdentityName = 'configDeployer'
var roleAssignmemtName = guid(resourceGroup().id, 'contributor')

var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')


resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: userAssignedIdentityName
  location: location
}

resource roleAssignmet 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmemtName
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'uploadFile'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.52.0'
    scriptContent: 'wget https://github.com/Tommaso23/Azure-Media-Services-environment/blob/master/code/functionApp.zip -O functions.zip  && az storage blob upload --account-name ${storageAccountName} --container-name ${blobContainerName} --name functionsCode --type block --file functions.zip --auth-mode login'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
