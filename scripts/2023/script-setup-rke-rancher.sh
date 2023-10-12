#!/bin/bash

printf "Public DNS: "
read EC2_PUBLIC_DNS
printf "Internal Address: "
read EC2_INT_ADDRESS
printf "RKE Version (https://github.com/rancher/rke/releases): "
read RKE_BIN_VERSION  
printf "K8S Version: "
read K8S_VERSION
printf "Rancher Repo (stable/latest): "
read RANCHER_REPO     
printf "Rancher version: "
read RANCHER_VERSION

export EC2_PUBLIC_DNS
export EC2_INT_ADDRESS
export RKE_BIN_VERSION
export K8S_VERSION
export RANCHER_REPO
export RANCHER_VERSION

sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo modprobe br_netfilter
sudo bash -c 'echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
sudo curl https://releases.rancher.com/install-docker/20.10.sh | sh
sudo usermod -G docker ubuntu
ssh-keygen -q -t rsa -N '' -f $HOME/.ssh/id_rsa <<<y >/dev/null 2>&1
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
###
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
sudo mv kubectl /usr/local/bin/
curl -LO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar xzvf helm-v3.6.3-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm
curl -LO https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xzvf k9s_Linux_x86_64.tar.gz
sudo mv k9s /usr/local/bin/
curl -LO https://github.com/rancher/rke/releases/download/$RKE_BIN_VERSION/rke_linux-amd64
chmod 755 rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
###
cat <<EOF>> cluster.sample
nodes:
    - address: $EC2_PUBLIC_DNS
      internal_address: $EC2_INT_ADDRESS
      user: ubuntu
      role:
        - controlplane
        - etcd
        - worker
kubernetes_version: $K8S_VERSION
cluster_name: rkeranchercluster
services:
  etcd:
    snapshot: true
    creation: 1h
    retention: 24h
#authentication:
#    strategy: x509
#    sans:
#      - "100.26.46.85"
#      - "ec2-100-26-46-85.compute-1.amazonaws.com"
EOF
envsubst < cluster.sample > cluster.yml
###
rke up
export KUBECONFIG=kube_config_cluster.yml
source <(kubectl completion bash)
kubectl get nodes
###
helm repo add rancher-$RANCHER_REPO https://releases.rancher.com/server-charts/$RANCHER_REPO
kubectl create namespace cattle-system
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.5.1
####
sleep 20
helm install rancher rancher-$RANCHER_REPO/rancher \
  --namespace cattle-system \
  --set hostname=$EC2_PUBLIC_DNS \
  --version $RANCHER_VERSION

