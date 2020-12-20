#!/bin/bash

# Variaveis para armazenar o JSON que sera utilizado no post do Zabbix, nao precisa de maiores controles, pois sera sobrescrito
JSON=`mktemp --suffix=-SLB `
JSON_AUTH=`mktemp --suffix=-SLB`

# SLB
SLB="$1"
USER="$2"
PASS="$3"

# Endpoint do SLB
SLB_API="http://$SLB/nitro/v1/stat"

# LOCKFILE
LOCK="/tmp/boxstatus.lck"

# STATUS

STATUS="protocoltcp"

KEYS="tcprxbytesrate"

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'

### LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
			echo $$ > $LOCK
			fn_check_status_protocoltcp_slb
	fi
	}

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $SLB -k $key -o $VALUE
        }


fn_check_status_protocoltcp_slb()
	{

	for key in `echo $KEYS`
		do
			KEYNAME="$key"
			VALUE=`curl -s -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API/$STATUS | grep errorcode | jq .$STATUS.$key`

			fn_send_zabbix
		done
	}

fn_gc()
	{
	 rm -f $LOCK
	 rm -f /tmp/*SLB
	}


fn_check_lock
fn_gc
