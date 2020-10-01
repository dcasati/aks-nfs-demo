# aks-nfs-demo
Get NFS 4.1 with AKS up and running. 


This procedure describes how to setup the CSI drivers for Kubernetes. Starting with version 1.21, Kubernetes will resort to
use the CSI drivers only. 

> NOTE: Please refer to this document for the latest on the CSI drivers with AKS: https://docs.microsoft.com/en-us/azure/aks/csi-storage-drivers

Pre-Requesites:

1. Kubernetes version: 1.17
1. Register the Azure Disk Container Storage Inferface (CSI) driver

```bash
az feature register --namespace "Microsoft.ContainerService" --name "EnableAzureDiskFileCSIDriver"
```

You can check if the feature was registered by using this command:

```bash
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/EnableAzureDiskFileCSIDriver')].{Name:name,State:properties.state}"
Name                                                     State
-------------------------------------------------------  -----------
Microsoft.ContainerService/EnableAzureDiskFileCSIDriver  Registered
```
1. Register the `AllowNfsFileShare` preview feature

```bash
az feature register --namespace "Microsoft.Storage" --name "AllowNfsFileShares"
```

You can check if the featured was registering by running:

```bash
az feature list -o table --query "[?contains(name, 'Microsoft.Storage/AllowNfsFileShares')].{Name:name,State:properties.state}"
```

When ready, run the following command to regresh the Microsoft.Storage resource provider.

```bash
az provider register --namespace Microsoft.Storage
```

1. Create a cluster that uses the CSI Driver

```bash
LOCATION=eastus2
az aks create -l $LOCATION -g MyResourceGroup -n MyManagedCluster --network-plugin azure -k 1.17.9 --aks-custom-headers EnableAzureDiskFileCSIDriver=true
```

1. Create a storage account 

```bash
STORAGERG=rg_dcasati_nfs
STORAGEACCT=dcasatinfs

az group create \
    --name $STORAGERG \
    --location $LOCATION

az storage account create \
    --name $STORAGEACCT \
    --resource-group $STORAGERG \
    --location $LOCATION \
    --sku Premium_LRS \
    --kind FileStorage
```
1. Create an NFS share

```bash
az storage share-rm create \
    --storage-account $STORAGEACCT \
    --enabled-protocols NFS \
    --root-squash RootSquash \
    --name "myshare"
```

1. Create a custom Storage Class for the Azure File CSI interface

```bash
cat << EOF > nfs-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi
provisioner: file.csi.azure.com
parameters:
  resourceGroup: $STORAGERG
  storageAccoun: $STORAGEACCT
  protocol: nfs
EOF

kubectl apply -f nfs-sc.yaml
```
## Testing with a Statefulset

1. Create a stateful set resource

```bash
kubectl create -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/statefulset.yaml
```
You can check the volume with this:
```bash
kubectl exec -it statefulset-azurefile-0 -- df -h
```
