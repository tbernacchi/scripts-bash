#!/bin/bash

SLB="$1"
USER="$2"
PASS="$3"

# Endpoint do SLB para verificar por vip
SLB_API="http://$SLB/nitro/v1/stat/lbvserver"

# LOCKFILE
LOCK="/tmp/slb-vip.lck"

# TEMP File
TEMP_FILE="/tmp/db.temp"

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
			fn_check_status_system_by_vip
	fi
	}

fn_send_zabbix_slb_health()
        {
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_HEALTH -o $SLB_HEALTH
        }

fn_send_zabbix_slb_status()
        {
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_STATUS -o $SLB_STATUS
        }

fn_send_zabbix_slb_rate_reqs_bytes()
	{
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_RATE_REQS_BYTES -o $SLB_RATE_REQS_BYTES
	}

fn_check_status_system_by_vip()
	{
	curl -s -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API | grep errorcode | jq . > $TEMP_FILE

	VIP_NAMES=`cat $TEMP_FILE | egrep -w "name" | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`

	for vip_name in `echo $VIP_NAMES`
		do
			SLB_HEALTH=`cat $TEMP_FILE | grep $vip_name -A5 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_health

			SLB_STATUS=`cat $TEMP_FILE | grep $vip_name -A9 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_status

			SLB_RATE_REQS_BYTES=`cat $TEMP_FILE | grep $vip_name -A18 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_rate_reqs_bytes


		done
	}


fn_gc()
	{
	rm $LOCK
	rm $TEMP_FILE
	}

fn_check_lock
fn_gc

