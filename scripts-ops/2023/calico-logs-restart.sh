#!/bin/bash
kubectl get pods -n kube-system | grep -i canal |  awk '{ if ($4 !~/0/) print $1 }' | while read x;do  kubectl logs -n kube-system $x -c calico-node |& gzip > $x.log.gz && kubectl logs -n kube-system $x -c calico-node -p |& gzip > $x.previous.log.gz;done
