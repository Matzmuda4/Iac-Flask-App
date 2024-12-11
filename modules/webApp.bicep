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

@secure()
param dockerRegistryServerUrl string

@secure()
param dockerRegistryServerUserName string

@secure()
param dockerRegistryServerPassword string

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: union(siteConfig, {
      acrUseManagedIdentityCreds: false
      dockerRegistryServerUrl: dockerRegistryServerUrl
      dockerRegistryServerUserName: dockerRegistryServerUserName
      dockerRegistryServerPassword: dockerRegistryServerPassword
    })
  }
}
