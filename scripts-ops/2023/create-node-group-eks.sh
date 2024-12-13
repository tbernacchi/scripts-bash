#!/bin/bash 
EMPTY_NODEGROUP="$(eksctl get nodegroups --cluster eks-para-rancher -o json | jq .[0].Name)"

# Delete nodegroup first
eksctl delete nodegroup --cluster eks-para-rancher --name "${EMPTY_NODEGROUP}"

# Then create a new nodegroup
eksctl create nodegroup --managed --cluster eks-para-rancher

