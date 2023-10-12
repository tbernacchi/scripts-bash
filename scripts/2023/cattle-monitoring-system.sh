#!/bin/bash
namespace=$(kubectl get namespace -A | grep -i monitoring | awk -F' ' '{ print $1 }') 
mkdir -p /tmp/$namespace-logs
kubectl get pods -n cattle-monitoring-system | cut -d ' ' -f1 | grep -iv name | while read x;do kubectl logs -n cattle-monitoring-system $x |& gzip > $x.log.gz && kubectl logs -n cattle-monitoring-system $x -p|& gzip > $x.previous.log.gz;done
