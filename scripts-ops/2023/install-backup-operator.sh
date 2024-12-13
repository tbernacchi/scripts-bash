#!/bin/bash
helm --kubeconfig kube_config_cluster.yml repo add rancher-charts https://charts.rancher.io
sleep 3
helm --kubeconfig kube_config_cluster.yml repo update
sleep 3
helm --kubeconfig kube_config_cluster.yml install rancher-backup-crd rancher-charts/rancher-backup-crd -n cattle-resources-system --create-namespace
sleep 3
helm --kubeconfig kube_config_cluster.yml install rancher-backup rancher-charts/rancher-backup -n cattle-resources-system
