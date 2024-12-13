#!/bin/bash
kubectl -n cattle-system get pods --no-headers -l app=rancher | cut -d ' ' -f1  |  while read x;do  kubectl logs -n cattle-system $x -c rancher |& gzip > $x.log.gz && kubectl logs -n cattle-system $x -c rancher -p |& gzip > $x.previous.log.gz;done

`which tar` czf rancher-pods.tar.gz 'rancher-*.log.gz' 2>&1 /dev/null
