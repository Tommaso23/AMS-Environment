param actions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabaseAccounts/items/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
]
param roleName string = 'CosmosDBReadWriteRole'
var roleDefName = guid(roleName)


resource RoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: roleName
    type: 'CustomRole'
    assignableScopes: [
      subscription().id
    ]
    permissions: [
      {
        actions: actions
      }
    ]
  }
}
