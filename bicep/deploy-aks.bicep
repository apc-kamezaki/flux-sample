@description('Application name')
param appName string = 'flux-demo'
@description('Location for resource')
param location string = resourceGroup().location

// settings for AKS
@description('Kubernetes cluster name')
param aksClusterName string = appName
@description('Availability zone for aks')
param aksAvailabilityZones array = [
  '1'
  '2'
  '3'
]
@description('Node disk size in GB')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0
@description('VM size for agent node')
param agentVMSize string = 'Standard_B4ms'
@description('The mininum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
param agentMinCount int = 2
@description('The maximum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
param agentMaxCount int = 5
@description('AKS cluster version')
param aksClusterVersion string = '1.22.6'


@description('vnet name')
param vnetName string = '${appName}-vnet'
@description('subnet name')
param subnetName string = '${vnetName}-aks-subnet'

@allowed([
  'azure'
  'calico'
])
@description('network plugin for network policy')
param networkPolicy string = 'azure'
@description('CIDR IP range for services')
param serviceCidr string = '172.29.0.0/16'
@description('IP address assigned to the Kubernetes DNS service. it can be inside the range of serviceCidr.')
param dnsServcieIP string = '172.29.0.10'
@description('CIDR IP range for docker bridge. It can not be the first or last address in its CIDR block')
param dockerBridgeCidr string = '172.17.0.1/16'

@description('ACR name')
param acrName string = replace(replace('${appName}acr', '-', ''), '_', '')

module aks 'bicep-templates/containers/aks-cluster.bicep' = {
  name: 'nested-aks-${appName}'
  params: {
    location: location
    clusterName: aksClusterName
    kubernetesVersion: aksClusterVersion
    osDiskSizeGB: osDiskSizeGB
    agentVMSize: agentVMSize
    agentMinCount: agentMinCount
    agentMaxCount: agentMaxCount
    availabilityZones: aksAvailabilityZones
    virtualNetworkName: vnetName
    subnetName: subnetName
    networkPolicy: networkPolicy
    serviceCidr: serviceCidr
    dnsServcieIP: dnsServcieIP
    dockerBridgeCidr: dockerBridgeCidr
    tags: {
      app: appName
    }
  }
}

module acr 'bicep-templates/containers/acr.bicep' = {
  name: 'nested-acr-${appName}'
  params:{
    location: location
    acrName: acrName
    targetPrincipalId: aks.outputs.principalId
    tags: {
      displayName: 'Container Registory for ${appName}'
      aksClusterName: aksClusterName
    }
  }
}
