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

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
  }
}
