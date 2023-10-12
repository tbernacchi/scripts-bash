#!/bin/bash 
#kubectl get serviceaccounts -A | grep -iv name| awk '{ print "serviceaccount:"$2,"namespace:"$1 }'
#kubectl get serviceaccounts -A | grep -iv name| awk '{ print "kubectl auth can-i '*' '*' --as "$2" --namespace "$1""}'
kubectl get serviceaccounts -A | grep -iv name| awk '{ print "kubectl auth can-i '*' '*' --as "$2" --namespace "$1""}' | sed -e 's/*/"*"/g'
