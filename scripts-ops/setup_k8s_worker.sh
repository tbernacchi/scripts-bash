#!/bin/bash
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

cat > /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
ip_vs
ip_vs_rr
ip_vs_sh
ip_vs_wrr
nf_conntrack_ipv4
EOF

echo "Upgrading system..."
apt update && apt upgrade -y

echo "Installing docker..."
curl -fsSL https://get.docker.com | bash

echo "Changing cgroup driver..."
cat > /etc/docker/daemon.json <<-EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo "Restarting docker..."
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker

echo "Installing all requirementes for k8s..."
apt-get update && apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
echo "kubectl completion bash" > /etc/bash_completion.d/kubectl
