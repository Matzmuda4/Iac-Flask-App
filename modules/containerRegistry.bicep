@description('Name of the Azure Container Registry')
param name string

@description('Location of the Azure Container Registry')
param location string

@description('Enable admin user for the registry')
param acrAdminUserEnabled bool

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output adminUsername string = containerRegistry.properties.adminUser.username
output adminPassword string = containerRegistry.properties.adminUser.password
