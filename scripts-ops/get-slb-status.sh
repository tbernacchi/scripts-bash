#!/bin/bash

# Variaveis para armazenar o JSON que sera utilizado no post do Zabbix, nao precisa de maiores controles, pois sera sobrescrito
JSON=`mktemp --suffix=-SLB `
JSON_AUTH=`mktemp --suffix=-SLB`

# SLB
SLB="$1"

# Endpoint do SLB
SLB_API="http://$SLB/nitro/v1/stat"

# Usuario e senha no SLB
USER="root"
PASS="Cbl2A98n"

# LOCKFILE
LOCK="/tmp/integrazbxjira.lck"

# STATUS

STATUS="protocoltcp"

### LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
			echo $$ > $LOCK
	fi
	}

fn_check_status_slb()
	{

	for status in `echo $STATUS`
		do
			curl -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API/$status | grep errorcode | jq
		done

	}

fn_check_status_slb

