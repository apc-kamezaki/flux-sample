@description('Application name')
param appName string = 'flux-demo'

// settings for AKS
@description('Kubernetes cluster name')
param aksClusterName string = appName

module flux 'bicep-templates/containers/enable-fux.bicep' = {
  name: 'deply-flux-${appName}'
  params: {
    clusterName: aksClusterName
  }
}
