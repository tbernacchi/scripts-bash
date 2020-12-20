#!/bin/sh

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

# Para trapper
HOST="softlayer"
KEY="event.slayer"


SL_USER="ambrosia.ambrosiano"
SL_APIKEY="504aaa21808b7d43def399d2d39a6b20bc1b0c33f3ea5c1d7fb304f4c6f454f7"

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'

# FILELOG
FILELOG="/tmp/incidentes-sl.log"
FILEMSG="/tmp/msg-eventos.log"

# LIMITE sao tres dias ((60 *60) * 24) * 3 em segundos
LIMITE="259200"

LOCK="/tmp/lck-slayer-eventos"

fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
			echo $$ > $LOCK
			# chamamos a funcao de coleta
			fn_get_active
	fi
	}

fn_send_zabbix()
	{
	$ZBXSND -z $ZBXPRX -s $HOST -k $KEY -o "$MSG"
	}

fn_get_all_objects()
	{
	curl -s -u $SL_USER:$SL_APIKEY 'https://api.softlayer.com/rest/v3.1/SoftLayer_Notification_Occurrence_Event/getAllObjects.json' > $FILELOG
	}

fn_get_active()
	{
	# Chamamos a funcao anterior
	fn_get_all_objects

	IDS_ACTIVE=`cat $FILELOG | jq '.[] | select(.statusCode.keyName=="ACTIVE")' | grep -w id | awk '{ print $2 }' | sed 's/,//g'`

	for id in `echo $IDS_ACTIVE`
		do
			DT_IM=`cat $FILELOG | jq . | grep -w $id -A2 | tail -n1 | awk '{ print $2 }' | cut -f1 -d"," | sed 's/"//g'`

			DT_IM_STAMP=`date -d $DT_IM +%s`

			HOJE=`date +%s`

			DIF=`echo "$HOJE - $DT_IM_STAMP" | bc`

			if [ $DIF -lt $LIMITE ]
				then
					cat $FILELOG | jq '.' | grep -w $id -B1 -A10 >> $FILEMSG
			fi
		done
	}

fn_check_for_send()
	{
	TTLN=`wc -l $FILEMSG | awk '{ print $1 }'`

	if [ $TTLN -gt 0 ]
		then
			MSG=`cat $FILEMSG | egrep "id|startDate|modifyDate|subject" | sed 's/"//g'`
			fn_send_zabbix
		else
			MSG="0"
			fn_send_zabbix
	fi
	}

fn_gc()
	{
	rm -f $FILELOG
	rm -f $FILEMSG
	rm -f $LOCK
	}

fn_check_lock
fn_check_for_send
fn_gc
