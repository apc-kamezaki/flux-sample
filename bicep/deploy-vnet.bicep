@description('Application name')
param appName string = 'flux-demo'
@description('Location for resource')
param location string = resourceGroup().location

@description('vnet name')
param vnetName string = '${appName}-vnet'
@description('aks subnet name')
param aksSubnetName string = '${vnetName}-aks-subnet'
@description('aks subnet address prefix')
param aksPrefix string = '10.1.0.0/16'
@allowed([
  'Enabled'
  'Disabled'
])
@description('private endpoint network pocilies of aks subnet')
param aksEndpointPolicy string = 'Enabled'
@allowed([
  'Enabled'
  'Disabled'
])
@description('private link service pocilies of aks subnet')
param aksServicePolicy string = 'Enabled'

var subnets = [
  {
    name: aksSubnetName
    prefix: aksPrefix
    endpointPolicy: aksEndpointPolicy
    servicePolicy: aksServicePolicy
  }
]

module vn 'bicep-templates/networks/vnet.bicep' = {
  name: 'deploy-${vnetName}'
  params: {
    virtualNetworkName: vnetName
    location: location
    subnets: subnets
    tags: {
      app: appName
    }
  }
}
