#!/bin/bash
docker rm -f $(docker ps -qa)
docker rmi $(docker images -a -q)
docker volume rm -f $(docker volume ls -q)
sudo -s
cleanupdirs="/var/lib/etcd /etc/kubernetes /etc/cni /opt/cni /var/lib/cni /var/run/calico"
for dir in $cleanupdirs; do
  echo "Removing $dir"
  rm -rf $dir
done
exit
