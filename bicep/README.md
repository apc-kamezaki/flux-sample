# How to deploy the resources


## Deploy each resources one by one

### deploy resource group

```shell
az deployment sub create -f deploy-resource-group.bicep --location japaneast \
    --parameters rgName=${RESOURCE_GROUP}
```

### deploy virtual network

```shell
az deployment group create -f deploy-vnet.bicep --resource-group $RESOURCE_GROUP
```

### deply aks and acr

Please set the latest cluster version for `aksClusterVersion` parameter before you install aks.
Please set the VM size for `agentVMSize` parameter, 

```shell
# check the latest version of aks cluster
az aks get-versions --location japaneast --output table

# Please set the latest cluster version for `aksClusterVersion` parameter before you install aks.
# Please set the VM size for `agentVMSize` parameter, 

# deploy aks and acr
az deployment group create -f deploy-aks.bicep --resource-group $RESOURCE_GROUP
```

### Deploy Flux extension and its configrations

```shell
az deployment group create -f deploy-flux.bicep --resource-group $RESOURCE_GROUP

az deployment group create -f deploy-flux-config.bicep --resource-group $RESOURCE_GROUP \
    --parameters @flux-parameters.json
```