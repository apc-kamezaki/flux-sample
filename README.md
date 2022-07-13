# Flux Sample

Deploy applicatoins on AKS using [Flux](https://fluxcd.io/)

# Deploy

## Prerequisit

Upgrade your az cli. Minimum version is 2.15.

```shell
az version
az upgrade
```

Enable some azure service providers

```shell
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration

# Registrations are asynchronous process and should finish within 10mins.
# please monitor progress

az provider show --namespace Microsoft.Kubernetes -o table
az provider show --namespace Microsoft.ContainerService -o table
az provider show --namespace Microsoft.KubernetesConfiguration -o table

```

You can see the result like this.

```
Namespace                          RegistrationPolicy    RegistrationState
---------------------------------  --------------------  -------------------
Microsoft.KubernetesConfiguration  RegistrationRequired  Registered
```

## Deploy AKS and other azure resources

## 

