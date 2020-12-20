#!/bin/bash
## Simple script to setup a master Kubernetes on Vagrant
## OS Version: Ubuntu 16.04
## author: Tadeu Bernacchi
## Date: 06/18/2020
ETH1="$(ifconfig eth1 | grep -v inet6 | grep inet | awk -F: '{ print $2 }'| awk '{ print $1 }')"
NET_K8S="$(kubectl describe svc kubernetes| grep "IP:"  | awk '{ print $2 }')"

echo "Turning swap off.."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "Enabling kernel modules..."
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

echo "Installing all requirementes for install k8s..."
apt-get update && apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
echo "Installing kubeadm kubelet kubectl..."
apt-get install -y kubelet kubeadm kubectl
apt install -y bash-completion
echo "kubectl completion bash" > /etc/bash_completion.d/kubectl

echo "Pulling images..."
kubeadm config images pull

echo "Kubeadm init..."
kubeadm init --apiserver-advertise-address $ETH1 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "Installing weave CNI..."
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "You can now join any number of machines by running the following on each node as root:"
kubeadm token create --print-join-command 2> /dev/null

echo "Dont forget to add a route for $NET_K8S on worker nodes!"
