#!/bin/bash
wget https://github.com/containerd/containerd/releases/download/v1.7.3/containerd-1.7.3-linux-arm64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mkdir -p /usr/local/bin/containerd
`which tar` Cxzvf /usr/local/bin/containerd containerd-1.7.3-linux-arm64.tar.gz
cd /usr/local/bin/containerd/bin
mv /usr/local/bin/containerd/bin/* /usr/local/bin/containerd/
cd /usr/local/bin/containerd/
rm -rf bin/
mkdir -p /etc/systemd/system/
cat containerd.service > /etc/systemd/system/containerd.service
sed -i 's#/usr/local/bin/containerd#/usr/local/bin/containerd/containerd#g' /etc/systemd/system/containerd.service
export PATH=$PATH:/usr/local/bin/containerd | tee -a ~root/.bashrc
systemctl daemon-reload
systemctl enable containerd
systemctl start containerd
mkdir -p /etc/containerd
/usr/local/bin/containerd/containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
