#!/bin/bash

SLB="$1"
USER="$2"
PASS="$3"

# Endpoint do SLB para verificar por vip
SLB_API_VIP="http://$SLB/nitro/v1/stat/lbvserver"

# Endpoint do SLB para verificar por servicegroup
SLB_API_SG="http://$SLB/nitro/v1/config/lbvserver_binding"

# LOCKFILE
LOCK="/tmp/slb-vip.lck"

# TEMP File
TEMP_FILE="/tmp/db-vip.temp"

# GROUP_FILES
TEMP_SG="/tmp/db-vip.sg"

# File Status
TEMP_STATUS="/tmp/db-vip.status"

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
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_HEALTH -o "$MSG"
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
	curl -s -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API_VIP | grep errorcode | jq . > $TEMP_FILE

	VIP_NAMES=`cat $TEMP_FILE | egrep -w "name" | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`

	for vip_name in `echo $VIP_NAMES`
		do
			SLB_HEALTH=`cat $TEMP_FILE | grep $vip_name -A5 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`

			if [ $SLB_HEALTH != 100 ]
				then
					echo "Eh diferente, pegamos o service group do vip e os seus reais"
					curl -s -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API_SG/$vip_name | grep errorcode | jq "." > $TEMP_SG-$vip_name

					 for IPREAL in `cat $TEMP_SG-$vip_name  | grep ipv46 | cut -f4 -d"\""`
						do 
							STATUS_REAL=`cat $TEMP_SG-$vip_name | grep $IPREAL -A3 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`

							PORT_REAL=`cat $TEMP_SG-$vip_name | grep $IPREAL -A 1 | tail -n1 | awk '{ print $2 }' | sed 's/,//g'`

							DNSCONV=`host $IPREAL 10.150.251.50 | grep pointer | awk '{ print $5 }'`

							echo "$DNSCONV $IPREAL na porta $PORT_REAL $STATUS_REAL" >> $TEMP_STATUS-$vip_name

							VALUES=`cat $TEMP_STATUS-$vip_name |  sed ':a;$!N;s/\n/ | /g;ta'`

							MSG="infslb - VIP $vip_name em $SLB_HEALTH% - Status do(s) servidor(es) $VALUES"
							fn_send_zabbix_slb_health
							
						 done
				else

					MSG="$SLB_HEALTH"
					fn_send_zabbix_slb_health
			fi

			SLB_STATUS=`cat $TEMP_FILE | grep $vip_name -A9 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_status

			SLB_RATE_REQS_BYTES=`cat $TEMP_FILE | grep $vip_name -A18 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_rate_reqs_bytes
		done
	}


fn_gc()
	{
	rm $LOCK
	rm /tmp/db-vip*
	}

fn_check_lock
#fn_gc

