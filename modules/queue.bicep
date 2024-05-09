param queueName string
param storageAccountName string


resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-04-01' = {
  name: '${storageAccountName}/default/${queueName}'
  properties: {
    metadata: {}
  }
}
