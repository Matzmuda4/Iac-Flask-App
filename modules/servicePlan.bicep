@description('Name of the Azure Service Plan')
param name string

@description('Location of the Azure Service Plan')
param location string

@description('The SKU properties for the Azure Service Plan')
param sku object

@description('Specifies if the plan is reserved for Linux workloads')
param reserved bool

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  sku: sku
  properties: {
    reserved: reserved
  }
}
