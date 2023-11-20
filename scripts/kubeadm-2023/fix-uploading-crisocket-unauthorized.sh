#!/bin/bash	
# In case you received this kind of message trying to add a node join the cluster:
# ...
# [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
# [kubelet-check] Initial timeout of 40s passed.
# error execution phase kubelet-start: error uploading crisocket: Unauthorized
# To see the stack trace of this error execute with --v=5 or higher
# These steps fixed the issue on the worker node.
swapoff -a # will turn off the swap
kubeadm reset
systemctl daemon-reload
systemctl restart kubelet
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X  # will reset iptables
