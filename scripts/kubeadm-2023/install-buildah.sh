#!/bin/bash
#It install buildah https://buildah.io/
#This script was executed on Ubuntu 20.04.6 LTS aarch64
apt-get -y update
apt-get install -y wget
apt-get -y install ca-certificates
apt-get -y install gnupg2
echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_20.04/Release.key -O /tmp/Release.key
apt-key add - < /tmp/Release.key
apt-get -y update -qq
apt-get install -y buildah
