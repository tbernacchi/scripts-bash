#!/bin/bash
echo "Installing..."
curl --silent -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
mv kubectl /usr/local/bin/
curl --silent -LO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar xzvf helm-v3.6.3-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm
curl --silent -LO https://github.com/rancher/rke/releases/download/v1.2.9/rke_linux-amd64
chmod 755 rke_linux-amd64
mv rke_linux-amd64 /usr/local/bin/rke
echo "Done!"
