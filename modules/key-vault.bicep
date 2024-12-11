@description('Name of the Key Vault')
param name string

@description('Location of the Key Vault')
param location string

@description('Enable vault for deployment')
param enableVaultForDeployment bool = true

@description('Array of role assignments')
param roleAssignments array = [
  {
    principalId: 'c52bb0cc-7f22-4c28-aee8-264d1cafbb06'
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: enableVaultForDeployment
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in roleAssignments: {
  name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionIdOrName)
  scope: keyVault
  properties: {
    principalId: assignment.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionIdOrName)
    principalType: assignment.principalType
  }
}]

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
