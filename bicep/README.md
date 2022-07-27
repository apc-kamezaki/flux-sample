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

```

### Add ACR Helm registry

```shell

# First you should create service principal for helm registry
SERVICE_PRINCIPAL_NAME=flux-demo-helm-registry
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME \
          --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
           --role acrpull \
          --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

kubectl create namespace flux-config


# authentication for helm registry
# first, create secret
kubectl create secret docker-registry helmrepocred \
 --namespace flux-config \
 --docker-server=$ACR_NAME.azurecr.io \
 --docker-username=$USER_NAME \
 --docker-password=$PASSWORD

 # then create flux source
flux create source helm acr-helm \
  --url=oci://$ACR_NAME.azurecr.io/helm \
  --namespace flux-config \
  --secret-ref=helmrepocred

# authentication for github repository
# how to create github PAT('Personal access token')
# see : https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

GITHUB_USER="Put your account"
GITHUB_TOKEN="Put your PAT here"
kubectl create secret generic sampleappscred \
 --namespace flux-config \
 --from-literal=username="$GITHUB_USER" \
 --from-literal=password="$GITHUB_TOKEN"

flux create source git sample-apps-private \
  --url=<put your private repo> \
  --namespace flux-config \
  --branch=main \
  --secret-ref=sampleappscred


```

### Deply flux configuration

```shell

az deployment group create -f deploy-flux-config.bicep --resource-group $RESOURCE_GROUP \
    --parameters @flux-parameters.json

```