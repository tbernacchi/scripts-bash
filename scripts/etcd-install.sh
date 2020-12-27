#!/bin/bash
##Install etcdctl client on Ubuntu 18.04
ETCD_VERSION=${ETCD_VERSION:-v3.3.13}

curl --silent -L https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz -o etcd-$ETCD_VERSION-linux-amd64.tar.gz

tar xzvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
rm etcd-$ETCD_VERSION-linux-amd64.tar.gz

cd etcd-$ETCD_VERSION-linux-amd64
sudo cp etcd /usr/local/bin/
sudo cp etcdctl /usr/local/bin/

rm -rf etcd-$ETCD_VERSION-linux-amd64

etcdctl --version
