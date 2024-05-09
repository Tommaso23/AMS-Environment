param roleDefName string
param roleName string
param roleDescription string
param actions array
param notActions array
param assignableScopes array

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
      }
    ]
    assignableScopes: assignableScopes
  }
}

output roleDefinitionId string = roleDef.id
