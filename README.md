# aks-nfs-demo
get NFS 4.1 with AKS up and running

```bash

LOCATION=eastus2
STORAGERG=rg_nfs
STORAGEACCT=fileshowto

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

cat << 'EOF' > nfs-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi
provisioner: file.csi.azure.com
parameters:
  resourceGroup: files-howto-resource-group 
  storageAccoun: fileshowto
  protocol: nfs
EOF

kubectl apply -f nfs-sc.yaml

kubectl create -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/statefulset.yaml

kubectl exec -it statefulset-azurefile-0 -- df -h
```
