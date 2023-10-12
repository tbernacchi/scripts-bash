#!/bin/bash
kubectl get pods -n cattle-logging-system | cut -d ' ' -f1 | grep -iv name | while read x;do  kubectl logs -n cattle-logging-system |& gzip > $x.log.gz && kubectl logs -n cattle-logging-system  -p|& gzip > $x.previous.log.gz;done

for pod in $(kubectl get pods -n cattle-logging-system | awk -F/ '{ if ($1 !~/1/) print $0 }' | grep -iv name | awk '{ print $1 }');do
  kubectl logs -n cattle-logging-system $pod -c fluentd |& gzip > $pod.log.gz
  kubectl logs -n cattle-logging-system $pod -c fluentd -p |& gzip > $pod.previous.log.gz
done

