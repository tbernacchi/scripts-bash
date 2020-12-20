#!/bin/bash
HOSTS="machine01.tabajara.intranet machine02.tabajara.intranet machine03.tabajara.intranet" 

for i in `echo $HOSTS`;do
    /usr/bin/sshpass -p 'password' ssh user@$i 'nc -zv glusterfs.tabajara.intranet 24007'
done