#!/bin/bash 
DNS1="10.150.251.50"
DNS2="192.168.4.53"
VLANQA="935-BE-DVHM"
VLANPROD="987-BE-PRO"
DESTFOLDERQA="Ambiente_de_QA"
DESTFOLDERPROD="Ambiente de Producao"
RSCPOOLQA="tabajaraQA"
RSCPOOLPROD="tabajaraPRD01"
DATASTOREQA="fbesx004_data"
DATASTOREPROD="fbesx001_data"
TEMPLATEVMWARE="template_LinuxCentOS7_16GB"

ITEMS="$(awk 'END {print NF}' machines.txt)" 

#Check all arguments 
if [ "${ITEMS}" -ne 4 ];then
	echo "ERROR: You should fill out all the necessary fields on the machines.txt, e.g: ip, netmask, gw, fqdn"
	exit 2
fi 

#Check domain
CHECKDOMAIN="$(cat machines.txt | awk '{ print $4 }' | awk -F. '{ print $2,$3,$4}' | sed 's/ /./g')"

#Short hostname
SHORTHOST="$(cat machines.txt | awk '{ print $4 }' | awk -F. '{ print $1 }')" 

#Deploy machines
if [ "${CHECKDOMAIN}" == "qa.tabajara.intranet" ]; then  
	while read ip netmask gw fqdn;do
		/usr/bin/knife vsphere vm clone "${SHORTHOST}" --template "${TEMPLATEVMWARE}" -f Template --distro chef-full \
		--bootstrap true --cdnsips "${DNS1},${DNS2}" --cdnssuffix "tabajara.intranet" --cdomain "qa.tabajara.intranet" \
		--cvlan "${VLANQA}" --cgw "${gw}" --cips "${ip}/${netmask}" --ssh-user root --ssh-password "mudar123" -N "${fqdn}" --fqdn "${fqdn}" \
 		--dest-folder "${DESTFOLDERQA}" --environment qa -r "recipe[bootstrap]" --ccpu 2 --cram 2 --resource-pool "${RSCPOOLQA}" --datastore "${DATASTOREQA}"
	done < machines.txt	
else 
	while read ip netmask gw fqdn;do
		/usr/bin/knife vsphere vm clone "${SHORTHOST}" --template "${TEMPLATEVMWARE}" -f Template --distro chef-full \
		--bootstrap true --cdnsips "${DNS1},${DNS2}" --cdnssuffix "tabajara.intranet" --cdomain "tabajara.intranet" \
		--cvlan "${VLANPROD}" --cgw "${gw}" --cips "${ip}/${netmask}" --ssh-user root --ssh-password "mudar123" -N "${fqdn}" --fqdn "${fqdn}" \
		--dest-folder "${DESTFOLDERPROD}" --environment prod -r "recipe[bootstrap]" --ccpu 2 --cram 2 --resource-pool "${RSCPOOLPROD}" --datastore "${DATASTOREPROD}" 
	done < machines.txt
fi 
#Add role[base-centos], remove recipe[bootstrap]
cat machines.txt | while read x; do
   FQDN=`echo $x | awk '{ print $4 }'`	
		/usr/bin/knife node run_list add "${FQDN}" "role[base-centos]"
		/usr/bin/knife node run_list remove "${FQDN}" "recipe[bootstrap]"
done
