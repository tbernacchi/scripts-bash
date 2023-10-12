#!/bin/bash
kubectl get globalrole,globalrolebindings --all-namespaces  -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name'
