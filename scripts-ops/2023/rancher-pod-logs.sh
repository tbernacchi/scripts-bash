#!/bin/bash 
for pod in $(kubectl get pods -n cattle-system -l app=rancher --no-headers -o custom-columns=":metadata.name")
  do
    kubectl logs -n cattle-system $pod -c rancher |& gzip > $pod.log.gz
    kubectl logs -n cattle-system $pod -c rancher -p |& gzip > $pod.previous.log.gz
done
