#!/bin/bash

# Script para obter o status dos jobs do rundeck

# Usuari0 e senha no zabbix e jira
USER="svc_zabbix_monit"
PASS="kwf4384R?"
ZBXPRX="zbxprx01.tabajara.local"
PRX_ID="10254"

# LOCKFILE
LOCK="/tmp/get-rundeck.lck"

# LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
		echo $$ > $LOCK
		fn_check_rundeck_9nfo
	fi
	}

	curl -s -H "Accept: application/json" -X GET "http://rundeck.tabajara.local:4440/api/2/system/info?authtoken=ixWUqfl9WwHxQ1inFEHbRDVXMF4nt4R2" 

