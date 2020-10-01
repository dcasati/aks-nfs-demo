# aks-nfs-demo
get NFS 4.1 with AKS up and running

1. Install the CSI Driver: https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/install-csi-driver-master.md

```bash

LOCATION=eastus2
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

STORAGEKEY=$(az storage account keys list \
    --resource-group $STORAGERG \
    --account-name $STORAGEACCT \
    --query "[0].value" | tr -d '"')

az storage share-rm create \
    --storage-account $STORAGEACCT \
    --enabled-protocols NFS \
    --root-squash RootSquash \
    --name "myshare"

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

kubectl create -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/statefulset.yaml

kubectl exec -it statefulset-azurefile-0 -- df -h
```
