param cosmosdbaccountName string
param cosmosdbsqlDatabaseName string
//param cosmosdbaccountNameId string


resource cosmosDBSQLDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  name: '${cosmosdbaccountName}/${cosmosdbsqlDatabaseName}'
  properties: {
    resource: {
      id: cosmosdbsqlDatabaseName
    }
  }
}
