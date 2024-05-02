param roleDefinitionId string
param principalId string
param cosmosDBAccountName string
param cosmosDBAccountId string

var roleAssignmentId = guid(roleDefinitionId, principalId, cosmosDBAccountId)

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: '${cosmosDBAccountName}/${roleAssignmentId}'
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    scope: cosmosDBAccountId
  }
}
