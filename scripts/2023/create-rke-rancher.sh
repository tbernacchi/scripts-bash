#!/bin/bash 
###Pre-requirements
#Instala o docker:
#curl -fsSL https://get.docker.com | bash
#systemctl enable docker && systemctl start docker
#-> No SSH:
#AllowTcpForwarding yes
#PermitRootLogin yes
#Port 22
#ListenAddress 172.31.14.74 <Ip interno do host) 
#systemctl restart sshd
#-> Gera uma ssh-key
#ssh-keygen
#-> Appende o conteudo da chave publica em ~root/.ssh/authorized_keys
###Finish-requirements

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
mv kubectl /usr/local/bin/
curl -LO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar xzvf helm-v3.6.3-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm
curl -LO https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xzvf k9s_Linux_x86_64.tar.gz
mv k9s /usr/local/bin/
curl -LO https://github.com/rancher/rke/releases/download/v1.2.9/rke_linux-amd64
chmod 755 rke_linux-amd64
mv rke_linux-amd64 /usr/local/bin/rke

#Setar o alias para o kubectl e helm 
alias k='kubectl --kubeconfig kube_config_cluster.yml'
alias helm='helm --kubeconfig kube_config_cluster.yml'

#Configura o cluster.yml e depois 'rke up'
##Singe node example cluster.yml

