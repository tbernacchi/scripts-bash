#!/bin/bash
WORKERS=
IP=`hostname -I | awk '{ print $2 }'`

check_worker_list() {
if [ -z "$WORKERS" ];then
	echo "The list of hosts from master it's empty adding this one $IP..."
	join_cluster
else
	add_worker
fi
}

join_cluster() {
        {{ hostvars['K8S_HOST']['join'] }}
}

add_worker() {
for i in `echo $WORKERS`;do
        if [ "$i" == "$IP" ];then
                echo "The host $IP it's already in to the cluster, exiting..."
		exit 0 
        fi
done
join_cluster 
}
check_worker_list 
