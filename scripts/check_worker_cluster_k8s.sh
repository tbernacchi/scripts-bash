#!/bin/bash
WORKERS="192.168.33.101 192.168.33.102 192.168.33.103"
IP="192.168.33.103"
#IP=`hostname -I | awk '{ print $2 }'`
LOCK_FILE=`mktemp --suffix=-IP`

join_cluster () {
	echo "Adding the host in to the cluster..."
}

check_worker () {
for i in `echo $WORKERS`;do
	if [ "$i" == "$IP" ];then
		OUTPUT="exist"
		echo "The host it's already in the cluster..."
	fi
done

if [ -z "$OUTPUT" ];then
	join_cluster
fi

}
check_worker
