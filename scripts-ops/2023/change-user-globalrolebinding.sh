#!/bin/bash
#TA COM PAU NA VARIAVEL ROLENAME - 15/06/2022.
#ROLENAME="$1"
#ROLENAME="user"
USERS="$(kubectl get users -o yaml | grep -i principalIds -A2 | sed 's/--//g'| sed 's/-//g' | sed 's/ //g' | awk -F: '{ print $1,$2 }'| grep -v principalIds | sed 's/\///'g | grep activedirectory_user -A1 | sed 's/--//g' | xargs -n4| awk '{ print $1,$2,$4 }' | awk '{if ($3) print $0;}' | sed 's/\(DC=space .\)\(.*\)/\1-\2/' | awk '{ print $3 }')"

export KUBECONFIG=kube_config_cluster.yml

for user in `echo $USERS`;do
	globalrolebindings=$(kubectl get globalrolebinding -o yaml | grep apiVersion -A17 -B17 | grep "userName: $user" -B18 | grep "name:" | grep -v "authz" | sed 's/ //g' | awk -F: '{ print $2 }')

	for grb in `echo $globalrolebindings`;do
		kubectl patch globalrolebinding $grb -p '{"globalRoleName": "user" }' --type='merge'
		#echo $grb
	done
done

#kubectl get globalrolebinding -o yaml | grep apiVersion -A17 -B17 | grep "userName: u-i6wyruzvpe" -B18
#kubectl patch globalrolebinding grb-78vmw -p '{"globalRoleName": "user" }' --type='merge'
