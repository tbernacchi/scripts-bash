#!/bin/bash
kubectl --kubeconfig kube_config_cluster.yml create namespace cert-manager
kubectl --kubeconfig kube_config_cluster.yml label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm --kubeconfig kube_config_cluster.yml install cert-manager --namespace cert-manager --version v1.5.1 jetstack/cert-manager
