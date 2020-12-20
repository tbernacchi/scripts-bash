#!/bin/sh

# Variaveis de tempo
DT=`date +%Y-%m-%d`

# LOG FORMAT: sms-mail-dispatcher.log.2018-04-24
FILELOG="/opt/app/logs/sms-mail-dispatcher.log.$DT"


DT_NOW=`date +%s`

HOUR_NOW=`date +%H | sed 's/^0//g'`

LAST_CHANGE=`stat -c %y $FILELOG`

DT_CONV=`date -d "$LAST_CHANGE" +%s`

DIF=`echo "$DT_NOW - $DT_CONV" | bc`

# quando comeca o dia
START_DAY="8"

LIMIT_08_22="900"
LIMIT_22_08="21600"

HOST=`hostname -s` 

## Agente de envio 
ZBXPRX="zbxprx01.tabajara.local" 
ZBXSND=$(which zabbix_sender)  
ZBXCONF="/etc/zabbix/zabbix_agentd.conf"

fn_send_zabbix_critical()         
	{         
	MSG_CRITICAL="$LAST_CHANGE - CRITICAL - Possivel problema com SMS Software Express"          
	$ZBXSND -c $ZBXCONF -k log-sms -o "$MSG_CRITICAL"         
	}  

fn_send_zabbix_ok()         
	{         
	$ZBXSND -c $ZBXCONF -k log-sms -o "0"        
	}

if [ $HOUR_NOW -lt $START_DAY ]
	then
		echo $LIMIT_22_08
		if [ $DIF -gt $LIMIT_22_08 ]
			then
				fn_send_zabbix_critical
			else
				fn_send_zabbix_ok
		fi 
	else
		echo $LIMIT_08_22
		if [ $DIF -gt $LIMIT_08_22 ]
			then
				fn_send_zabbix_critical
			else
				fn_send_zabbix_ok
		fi
fi


