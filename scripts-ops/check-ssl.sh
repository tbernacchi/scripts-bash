#!/bin/sh

# O dns testado
name="$1"

# O IP do VIP (veja no balanceador)
ENDIPS="$2"

LIMITDAY_WARN="60"
LIMITDAY_CRIT="30"

HOST=`hostname -f`


## Agente de envio 
ZBXPRX="zbxprx01.tabajara.local" 
ZBXSND=$(which zabbix_sender)

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'

fn_send_zabbix()
	{
	MSG="$name IP: $endip exp $expiry_days dias - $LEVEL"

	$ZBXSND -z $ZBXPRX -s certificados -k $name -o "$MSG"
	}

fn_check_cert()
	{

		now_epoch=$( date +%s )
		expiry_date=$( echo | openssl s_client -showcerts -servername $name -connect $endip:443 2>/dev/null | openssl x509 -inform pem -noout -enddate | cut -d "=" -f 2 )
		echo -n " $expiry_date"
		expiry_epoch=$( date -d "$expiry_date" +%s )
		expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"

		if [ $expiry_days -lt $LIMITDAY_CRIT ]
			then
				LEVEL="CRIT"
				fn_send_zabbix

			elif [ $expiry_days -gt $LIMITDAY_CRIT ] && [ $expiry_days -lt $LIMITDAY_WARN ]
				then
					LEVEL="WARN"
					fn_send_zabbix
			else
				LEVEL="OK"
				fn_send_zabbix
		fi
	}

fn_exec_test()
	{
	for endip in `echo $ENDIPS`
		do
			fn_check_cert
		done
	} 

fn_exec_test
