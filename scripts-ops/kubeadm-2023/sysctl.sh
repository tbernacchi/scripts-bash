#!/bin/bash
cat > /etc/sysctl.d/k8s.conf <<-EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo modprobe br_netfilter
sudo sysctl --system

sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
