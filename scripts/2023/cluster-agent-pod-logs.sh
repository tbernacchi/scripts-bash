#!/bin/bash
for pod in $(kubectl get pods -n cattle-system -l app=cattle-cluster-agent --no-headers -o custom-columns=":metadata.name")
  do
    kubectl logs -n cattle-system $pod |& gzip > $pod.log.gz
    kubectl logs -n cattle-system $pod -p |& gzip > $pod.previous.log.gz
done
