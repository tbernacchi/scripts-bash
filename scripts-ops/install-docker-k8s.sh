#!/bin/bash
##To perform pre-requirements setup to K8S Cluster with Docker to CKA 1.19 version.
swapoff -a
#Dont forget to disable swap on '/etc/fstab' too!

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

###DOCKER - Ubuntu 18.04
#https://www.hostinger.com/tutorials/how-to-install-docker-on-ubuntu

apt-get install -y apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-cache policy docker-ce
apt install docker-ce=5:19.03.14~3-0~ubuntu-bionic -y
apt-mark hold docker-ce

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

systemctl daemon-reload
systemctl restart docker

###KUBERNETES
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

#apt-get update
#apt install kubelet=1.19.1-00 kubeadm=1.19.1-00 kubectl=1.19.1-00
#apt-mark hold kubelet kubeadm kubectl
#kubeadm init --ignore-preflight-errors all
#kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
