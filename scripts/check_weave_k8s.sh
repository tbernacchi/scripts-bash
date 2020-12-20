#!/bin/bash
WEAVE="$(kubectl get pods -n kube-system | grep weave | awk '{ print $1 }' | head -n1)"

if [ -z "$WEAVE" ] || [ ! -f /tmp/weave_install.status ];then
	kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
	touch /tmp/weave_install.status
else
	rm -rf /tmp/weave_install.status
fi
