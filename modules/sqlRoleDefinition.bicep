
param actions array = [
  //'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/items/*'
  //'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]
param roleName string = 'CosmosDBReadWriteRole'
param cosmosdbAccountId string
param cosmosdbAccountName string
//param sqlDatabaseName string
var roleDefName = guid(roleName)



resource RoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-11-15' = {
  name: '${cosmosdbAccountName}/${roleDefName}'
  properties: {
    roleName: roleName
    type: 'CustomRole'
    assignableScopes: [
      cosmosdbAccountId
      ]
    permissions: [
      {
        dataActions: actions
      }
    ]
  }
}

output roleDefinitionId string = RoleDefinition.id


