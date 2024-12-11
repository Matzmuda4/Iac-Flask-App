@description('Name of the Azure Web App')
param name string

@description('Location of the Azure Web App')
param location string

@description('The kind of the Azure Web App')
param kind string

@description('The ID of the App Service Plan')
param serverFarmResourceId string

@description('The site configuration for the Azure Web App')
param siteConfig object

@description('Docker Registry Server URL')
@secure()
param dockerRegistryServerUrl string

@description('Docker Registry Server Username')
@secure()
param dockerRegistryServerUserName string

@description('Docker Registry Server Password')
@secure()
param dockerRegistryServerPassword string

var dockerSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: union(siteConfig, {
      acrUseManagedIdentityCreds: false
      appSettings: union(dockerSettings, siteConfig.appSettingsKeyValuePairs)
    })
  }
}

output id string = webApp.id
output name string = webApp.name
