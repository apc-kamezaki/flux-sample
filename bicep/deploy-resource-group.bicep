// this file can only be deployed at a subscription scope
targetScope = 'subscription'

@description('Application name')
param appName string = 'flux-demo'
@description('location for general purpose resource group')
param location string = deployment().location
@description('Resource group name for general purpose')
param rgName string = appName


module rg 'bicep-templates/generals/resource-group.bicep' = {
  name: 'nested-resource-group'
  params: {
    name: rgName
    location: location
    tags: {
      app: appName
    }
  }
}

output id string = rg.outputs.id
output name string = rgName
