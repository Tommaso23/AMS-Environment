param blobServiceName string
param storageAccountName string

resource blobSevice 'Microsoft.Storage/storageAccounts/blobServices@2023-04-01' = {
  name: '${storageAccountName}/${blobServiceName}'
  properties: {
    cors: {
      corsRules: [
        {
          allowedHeaders: [
            ''
          ]
          allowedMethods: [
            'GET'
            'POST'
            'PUT'
          ]
          allowedOrigins: [
            '*'
          ]
          exposedHeaders: [
          
          ]
          maxAgeInSeconds: 20
        }
      ]
    }
  }
}
