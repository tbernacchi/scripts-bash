#!/bin/bash
kubectl get pods -n cattle-monitoring-system | cut -d ' ' -f1 | grep -iv name | while read x;do kubectl logs -n cattle-monitoring-system $x |& gzip > $x.log.gz && kubectl logs -n cattle-monitoring-system $x -p|& gzip > $x.previous.log.gz;done && tar czf cattle-monitoring-system.tar.gz *.log.gz && rm -f *.log.gz
