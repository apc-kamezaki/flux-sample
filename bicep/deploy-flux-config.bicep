@description('Application name')
param appName string = 'flux-demo'
@description('AKS cluster name')
param clusterName string = appName
@description('Flux extension name')
param fluxName string = 'flux'

@description('Flux configuration name')
param fluxConfigName string = '${appName}-${fluxName}-config'

@description('target repository url')
param gitRepositoryUrl string
@description('target repository branch name')
param targetBranch string = 'main'

@description('sync interval time')
param syncIntervalInSeconds int = 120

// Flux configuration namespace - it must be same as flux infrastructure's configuration
var fluxConfigNamespace = 'flux-config'

resource aks 'Microsoft.ContainerService/managedClusters@2022-04-01' existing = {
  name: clusterName
}

resource fluxExtension 'Microsoft.KubernetesConfiguration/extensions@2022-04-02-preview' existing = {
  name: fluxName
  scope: aks
}

resource fluxConfig 'Microsoft.KubernetesConfiguration/fluxConfigurations@2022-03-01' = {
  name: fluxConfigName
  scope: aks
  properties: {
    scope: 'cluster'
    namespace: fluxConfigNamespace
    sourceKind: 'GitRepository'
    gitRepository: {
      url: gitRepositoryUrl
      repositoryRef: {
        branch: targetBranch
      }
      syncIntervalInSeconds: syncIntervalInSeconds
    }
    kustomizations: {
      infra: {
        path: './infrastructure'
        syncIntervalInSeconds: syncIntervalInSeconds
        prune: true
      }
      apps: {
        path: './apps/staging'
        syncIntervalInSeconds: syncIntervalInSeconds
        prune: true
      }
    }
  }
}
