#!/bin/bash
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm --kubeconfig kube_config_cluster.yml install --name cert-manager --namespace cert-manager --version v0.14.2 jetstack/cert-manager
