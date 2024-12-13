#!/bin/bash
kubectl --kubeconfig kube_config_cluster.yml create namespace cattle-system
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
helm --kubeconfig kube_config_cluster.yml install rancher rancher-stable/rancher \ 
  --namespace cattle-system \ 
  --set hostname=tadeu.support.rancher.space \
  --set replicas=3 \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=tadeu.bernacchi@suse.com --version 2.5.9

###
Error: unable to build kubernetes objects from release manifest: unable to recognize "": no matches for kind "Issuer" in version "cert-manager.io/v1"

-> Precisa instalar o CRD:
k apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml
