#!/bin/bash
for pod in $(kubectl get pods -n kube-system -l k8s-app=canal --no-headers -o custom-columns=":metadata.name") 
do 
  kubectl logs -n kube-system $pod -c calico-node |& gzip > $pod.log.gz
  kubectl logs -n kube-system $pod -c calico-node -p |& gzip > $pod.previous.log.gz
done
