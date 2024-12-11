param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string
param location string
param keyVaultName string

// Deploy Azure Container Registry
module acr 'modules/containerRegistry.bicep' = {
  name: 'deployContainerRegistry'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVault.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: 'acrUsername'
    adminCredentialsKeyVaultSecretUserPassword1: 'acrPassword'
    adminCredentialsKeyVaultSecretUserPassword2: 'acrPassword2'
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
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettingsKeyValuePairs: {
        WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
        DOCKER_REGISTRY_SERVER_URL: acr.outputs.loginServer
        DOCKER_REGISTRY_SERVER_USERNAME: acr.outputs.adminUsername
        DOCKER_REGISTRY_SERVER_PASSWORD: acr.outputs.adminPassword
      }
    }
    dockerRegistryServerUrl: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}secrets/acrLoginServer)'
    dockerRegistryServerUserName: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}secrets/acrUsername)'
    dockerRegistryServerPassword: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}secrets/acrPassword)'
  }
}

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
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
