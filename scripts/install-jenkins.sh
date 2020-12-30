#!/bin/bash
# Install jenkins Jenkins 2.263.1 on Ubuntu 18.04
apt update -y
apt install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo 'deb http://pkg.jenkins.io/debian-stable binary/' > /etc/apt/sources.list.d/jenkins.list
apt update -y
apt install jenkins -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker jenkins
apt install -y python3-pip && pip3 install ansible && pip3 install openshift
