param queueName string
param storageAccountName string


resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  name: '${storageAccountName}/default/${queueName}'
  properties: {
    metadata: {}
  }
}
