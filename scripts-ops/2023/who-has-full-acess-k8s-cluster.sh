#!/bin/bash
#This script it's show if a local user has full acess to the k8s cluster.
#Need improve to one that could check 'kubectl get users' and check entries for LDAP
#For example:
#  principalIds:
#  - activedirectory_user://CN=sstanfor-Scott-Stanford,OU=_Users,DC=hq,DC=netapp,DC=com
#  - local://u-u2cqhhpm3i
#
# And then work with this:
# kubectl get globalrole,globalrolebindings --all-namespaces  \ 
# -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name, \ 
# SERVICE_ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name' | grep "u-u2cqhhpm3i"
#
kubectl get serviceaccounts -A | grep -iv name| awk '{ print $2,$1 }' > /tmp/serviceaccounts.txt

while read serviceaccount namespace ;do
	output=$(`which kubectl` auth can-i '*' '*' --as $serviceaccount --namespace $namespace)
		if [ $output == 'yes' ];then
			echo "serviceaccount $serviceaccount on $namespace has full access on cluster"
		fi
done < /tmp/serviceaccounts.txt
