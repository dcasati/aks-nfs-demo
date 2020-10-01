#!/usr/bin/env bash

echo "Install the CSI driver on the cluster now"
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/v0.9.0/deploy/install-driver.sh | bash -s v0.9.0 --

echo "checking if the csi-azurefile-controller is up. CTRL+C to proceed"
kubectl -n kube-system get pod -o wide --watch -l app=csi-azurefile-controller

echo "checking if the csi-azurefile-node is up. CTRL+C to proceed"
kubectl -n kube-system get pod -o wide --watch -l app=csi-azurefile-node
