#!/bin/bash
WORKERS="$(kubectl get nodes -o wide | grep -v master | grep -i ready | awk '{ print $6 }')"
LIST="$(echo $WORKERS | xargs | while read x;do echo "WORKERS='$x'";done)"

if [ -n "$WORKERS" ];then
	/bin/sed -i "s/`head -2 /usr/local/bin/join_worker_node.sh | tail -1 `/$LIST/" /usr/local/bin/join_worker_node.sh
fi

