param storageAccountName string
param location string 

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01'= {
  name: storageAccountName
  location: location
  tags: {
    owner: 'tagValue'
  }
  sku: {
    name: 'Standard_LRS'
    //tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

output blobEndpoint string = replace(replace(storageAccount.properties.primaryEndpoints.blob, 'https://', ''), '/', '')

output storageAccountKey string = storageAccount.listKeys().keys[0].value

