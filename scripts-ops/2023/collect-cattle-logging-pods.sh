#!/bin/bash
for pod in $(kubectl get pods -n cattle-logging-system | grep -iv name | awk '{ if ($4 !~/0/) print $0 }' | awk '{ print $1 }');do
  kubectl logs -n cattle-logging-system $pod | & gzip > "$pod".log.gz
  kubectl logs -n cattle-logging-system $pod -p | & gzip > "$pod".previous.log.gz
done
