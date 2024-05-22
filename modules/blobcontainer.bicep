param blobContainerName string
param storageAccountName string


resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' = {
  name: '${storageAccountName}/default/${blobContainerName}'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'Blob'
  }
}
