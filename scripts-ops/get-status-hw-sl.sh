#!/bin/sh

# Script para coletar o estado do HW servido na SL
# O script enviara via zabbix-trapper item que podera
# ser adicionado no Grafana
#  ipmitool -H 10.150.25.28 -U root -P KYEEhbYz63  sdr

# autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Data: 20/12/2018

# Variaveis

# Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'

DIRDB="/tmp/db-ipmi"

# Items no geral para graficos (alguns podem ter alarmes, mas vai precisar de tempo
ITEMS_VALS="$DIRDB/items"
VALUES_VALS="$DIRDB/values"
REPORT_FL="$DIRDB/report.log"

# Items para alarmes
ALARMS_ITEMS="$DIRDB/alarm-items"
ALARMS_VALS="$DIRDB/alarm-vals"
REPORT_FL_ALARMS="$DIRDB/report-alarm.log"

test -d /tmp/db-ipmi > /dev/null
if [ `echo $?` -eq 1 ]
	then
		mkdir $DIRDB
fi 

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $HST -k $KEY -o "$VALUE"
        }

IPMI_IPS="10.150.25.46 \
	  10.150.25.28 \
	  10.150.154.69 \
	  10.150.238.248 \
	  10.150.238.239 \
	  10.150.238.226 \
	  10.150.164.2 \
	  10.150.238.231 \
	  10.150.164.7 \
	  10.150.23.249"

fn_exec_get_items()
	{
	ipmitool -H $ipmi_ip -U root -P $PASS sdr > $DIRDB/result-$ipmi_ip

	# tratando items
	cat $DIRDB/result-$ipmi_ip | awk -F"|" '{ print $1 }' | sed 's/ \+/-/g' | sed 's/-$//g' > $ITEMS_VALS-$ipmi_ip
	cat $DIRDB/result-$ipmi_ip | awk -F"|" '{ print $2 }' | sed 's/ \+/-/g' | sed 's/-$//g' | cut -f2 -d"-" > $VALUES_VALS-$ipmi_ip
	paste -d ";" $ITEMS_VALS-$ipmi_ip $VALUES_VALS-$ipmi_ip > $REPORT_FL-$ipmi_ip

	# Primeiro envia dados para os graficos
	KEYS=`cat $REPORT_FL-$ipmi_ip | cut -f1 -d";"`

	for KEY in `echo $KEYS`
		do
			VALUE=`grep $KEY $REPORT_FL-$ipmi_ip | cut -f2 -d";"`

			# send zabbix
			fn_send_zabbix
		done

	#==================================================================================#
	# Segundo envia dados para alarms
	 ipmitool -H $ipmi_ip -U root -P $PASS  chassis status > $DIRDB/result-alarm-$ipmi_ip

	# tratando os items
	cat $DIRDB/result-alarm-$ipmi_ip | awk -F":" '{ print $1 }'  | sed 's/ \+/-/g' | sed -e 's/-$//g' -e 's/\//-/g'> $ALARMS_ITEMS-$ipmi_ip
	cat $DIRDB/result-alarm-$ipmi_ip | awk -F":" '{ print $2 }' | sed 's/ \+//g' > $ALARMS_VALS-$ipmi_ip
	paste -d ";" $ALARMS_ITEMS-$ipmi_ip $ALARMS_VALS-$ipmi_ip > $REPORT_FL_ALARMS-$ipmi_ip

	# Primeiro envia dados para os alarm
	KEYS=`cat $REPORT_FL_ALARMS-$ipmi_ip | cut -f1 -d";"`


	for KEY in `echo $KEYS`
		do
			VALUE=`grep $KEY $REPORT_FL_ALARMS-$ipmi_ip | cut -f2 -d";"`

			# send zabbix
			fn_send_zabbix
		done

	#==================================================================================#
	}

fn_conn_server()
	{
	for ipmi_ip in `echo $IPMI_IPS`
		do
			case "$ipmi_ip" in
				10.150.25.46)
					HST="ipmi-brasa01.tabajara.intranet"
					PASS="SDNXAsl77e"
					fn_exec_get_items
				;;

				10.150.25.28)
					HST="ipmi-butanclan01.tabajara.intranet"
					PASS="KYEEhbYz63"
					fn_exec_get_items
				;;

				10.150.154.69)
					HST="ipmi-zodiaco01.tabajara.intranet"
					PASS="J9W9mTwhsH"
					fn_exec_get_items
				;;

				10.150.238.248)
					HST="ipmi-fbesx001.tabajara.intranet"
					PASS="J92bZUhdQd"
					fn_exec_get_items
				;;

				10.150.238.239)
					HST="ipmi-fbesx002.tabajara.intranet"
					PASS="WEG3flw5hf"
					fn_exec_get_items
				;;

				10.150.238.226)
					HST="ipmi-fbesx003.tabajara.intranet"
					PASS="MXcDsm39Rl"
					fn_exec_get_items
				;;

				10.150.164.2)
					HST="ipmi-fbovm01.tabajara.intranet"
					PASS="D7vmf2rGrl"
					fn_exec_get_items
				;;

				10.150.238.231)
					HST="ipmi-fbovm02.tabajara.intranet"
					PASS="X7dXZC4k9k"
					fn_exec_get_items
				;;

				10.150.164.7)
					HST="ipmi-fbovm03.tabajara.intranet"
					PASS="T9YECHxnNT"
					fn_exec_get_items
				;;

				10.150.23.249)
					HST="ipmi-vyatta02.tabajara.intranet"
					PASS="V3K8wBu2vP"
					fn_exec_get_items
				;;

			esac
		done
	}

fn_gc()
	{
	rm -f $DIRDB/*
	}

# Executa o main
fn_conn_server
fn_gc
