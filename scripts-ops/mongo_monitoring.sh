#!/bin/bash
# Script to monitor the state of the mongo-cluster
# Autor: Tadeu Bernacchi
# Email: tadeu.bernacchi@tabajara.com.br | tbernacchi@gmail.com 
# Date:  08/06/2019
MONGO_ALL="$(/usr/bin/mongo --quiet -u mongoadmin -p 'tabajara#2018' admin -eval "JSON.stringify(rs.status())" | jq '.members[]| "\(._id) \(.name) \(.state) \(.stateStr)"' | sed 's/"//g'| sed 's/ /_/g')"

ZBXPRX="zabbix-homolog.hml1.tabajara.local"
ZBXSND=$(which zabbix_sender)
AGR="mongo-cluster"

fn_send_zabbix() {
    $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$VALUE"
}

#Cluster
fn_mongo_down () {
for mongo in `echo $MONGO_ALL`;do
	ID="$(echo $mongo| sed 's/_/ /g' | awk '{ print $1 }')"
	HOST="$(echo $mongo| sed 's/_/ /g' | awk -F: '{ print $1 }' | awk '{ print $2 }')"
    	STATE="$(echo $mongo| sed 's/_/ /g' | awk '{ print $3 }')"
    	STATE_CLUSTER="$(echo $mongo| sed 's/_/ /g' | awk '{ print $4 }')"
		
		for state in `echo $STATE`;do 
			if [ "$state" -eq 8 ];then
				VALUE="CRITICAL - Mongo cluster node $HOST is DOWN"
				KEY="STATE"
				fn_send_zabbix
			else 
				VALUE="0"
				KEY="STATE"
				fn_send_zabbix
			fi 
		done
done
} 

#Replication lag
REPLAG="$(mongo --quiet -u mongoadmin -p 'tabajara#2018' admin -eval "JSON.stringify(rs.printSlaveReplicationInfo())" | grep source -A 3 | sed 's/://g' | awk '{ print $1,$2 }' | sed 's/27/ /g' | grep -v synced | sed 's/source/ /g' | sed 's/  //g' | awk '{ print $1 }'| paste -s -d ',\n')"

REPCOLUMN="$(echo $REPLAG |sed ':a;$!N;s/ /\n/g;ta' | sed 's/,/ /g')" 

fn_slave_repl_lag () {
for replag in `echo $REPCOLUMN| awk '{ print $1}'`;do 
	SECONDS="$( echo $VAR | grep $replag | awk '{ print $2 }' )"
		if [ "$SECONDS" -ge 10 ];then
			VALUE="WARNING - Mongo cluster $replag is "$SECONDS"s behind the primary"
			KEY="DELAY"
			fn_send_zabbix
		else
			VALUE="0"
			KEY="DELAY"
			fn_send_zabbix
		fi
done
}

#Memory
fn_mongo_mem () { 
MEM_MONGO="$(mongo --quiet -u mongoadmin -p 'tabajara#2018' admin -eval "JSON.stringify(db.serverStatus().mem)" | jq '.resident')"
FREE="$(free | awk '{ print $2 }' | grep -v used | head -n1)"
perc=`echo "scale=2; ($MEM_MONGO/$FREE) * 100" | bc -l`
	
	if [ $perc -ge 80 ];then 
		VALUE="WARNING - Mongo cluster memory it's high $perc%"
		KEY="MEM"
		fn_send_zabbix
	else	
		VALUE="0"
		KEY="MEM"
		fn_send_zabbix
	fi
} 

#Connections
fn_mongo_connection () { 
CURRENT="$(mongo --quiet -u mongoadmin -p 'tabajara#2018' admin -eval "JSON.stringify(db.serverStatus().connections)" | jq '.current')"
AVAILABLE="$(mongo --quiet -u mongoadmin -p 'tabajara#2018' admin -eval "JSON.stringify(db.serverStatus().connections)" | jq '.available')"

perc=`echo "scale=2; ($CURRENT/$AVAILABLE) * 100" | bc -l`
	if [ $perc -ge 80 ];then 
		VALUE="WARNING - Mongo cluster too many connections"
		KEY="CON"
		fn_send_zabbix
	else	
		VALUE="0"
		KEY="CON"
		fn_send_zabbix
	fi
}

fn_mongo_down
fn_slave_repl_lag
fn_mongo_mem
fn_mongo_connection
