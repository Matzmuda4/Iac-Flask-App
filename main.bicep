param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string
param location string
param keyVaultName string

// Add these new parameters
@secure()
param adminCredentialsKeyVaultSecretUserName string = 'acrUsername'
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string = 'acrPassword1'
@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string = 'acrPassword2'

// Deploy Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'deployKeyVault'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: 'c52bb0cc-7f22-4c28-aee8-264d1cafbb06'
        roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// Deploy Azure Container Registry
module acr 'modules/containerRegistry.bicep' = {
  name: 'deployContainerRegistry'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVault.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: adminCredentialsKeyVaultSecretUserName
    adminCredentialsKeyVaultSecretUserPassword1: adminCredentialsKeyVaultSecretUserPassword1
    adminCredentialsKeyVaultSecretUserPassword2: adminCredentialsKeyVaultSecretUserPassword2
  }
}

// Deploy Azure App Service Plan
module appServicePlan 'modules/servicePlan.bicep' = {
  name: 'deployAppServicePlan'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module webApp 'modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.id
    dockerRegistryServerUrl: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}secrets/acrLoginServer)'
    dockerRegistryServerUserName: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}secrets/acrUsername)'
    dockerRegistryServerPassword: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}secrets/acrPassword)'
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettingsKeyValuePairs: {
        WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      }
    }
  }
}
