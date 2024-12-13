#!/bin/bash
kubectl get pods -n cattle-logging-system | cut -d ' ' -f1 | grep -iv name | while read x;do  kubectl logs -n cattle-logging-system $x |& gzip > $x.log.gz && kubectl logs -n cattle-logging-system $x -p|& gzip > $x.previous.log.gz;done
