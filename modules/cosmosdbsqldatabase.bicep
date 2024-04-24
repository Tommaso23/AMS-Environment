param cosmosdbaccountName string
param cosmosdbsqlDatabaseName string


resource cosmosDBSQLDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  name: '${cosmosdbaccountName}/${cosmosdbsqlDatabaseName}'
  properties: {
    resource: {
      id: 'tom-encoder-db'
    }
  }
}
