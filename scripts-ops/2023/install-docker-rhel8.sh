#!/bin/bash
#releases antigas: 
#https://download.docker.com/linux/centos/7/x86_64/stable/Packages/ 
#https://centos.pkgs.org/8/docker-ce-x86_64/docker-ce-cli-20.10.7-3.el8.x86_64.rpm.html
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update
yum install docker-ce-3:20.10.9-3.el8 docker-ce-cli-1:20.10.9-3.el8 containerd.io
systemctl enable docker && systemctl start docker
usermod -G docker ec2-user
