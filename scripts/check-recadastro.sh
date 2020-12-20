#!/bin/sh

# Script para monitorar o status do recadastro
# Este sistema nao eh de alta criticidade e por isso nao esta no SLB

# Executa um curl com o header igual ao Virtual Host para fazer match

SERVERS="zerado01.tabajara.intranet"

DNS="recadastro.tabajara.intranet"
PROBE="recadastro/actuator/health"

ZBXPRX="zbxprxapp01.tabajara.intranet"
ZBXSND=$(which zabbix_sender)
AGR="recadastro"
KEY="PROBE"
FILE="/tmp/falha-probe-recad"

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$MSG"
        }

for SRV in `echo $SERVERS`
	do
		RESULT=`curl -s --connect-timeout 5 --header 'Host: recadastro.tabajara.intranet' http://$SRV/$PROBE | grep -w  "UP"`

		if [ `echo $?` != 0 ]
			then
				echo "Falha no probe do recadastro - Host: $SRV" >> $FILE
		fi
	done

		TTL=`wc -l $FILE | awk '{ print $1 }'`

		if [ $TTL -gt 0 ]
			then
				MSG=`cat $FILE`
				fn_send_zabbix
			else
				MSG="0"
				fn_send_zabbix
		fi

rm $FILE
