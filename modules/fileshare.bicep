param fileShareName string
param storageAccountName string


resource storageAccountAssetFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-04-01' = {
  name: '${storageAccountName}/default/${fileShareName}'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
}

