#!/bin/sh

SERVERS="qzuriel01.tabajara.intranet \
	qzuriel02.tabajara.intranet \ 
	qzuriel03.tabajara.intranet \ 
	qzuriel04.tabajara.intranet \ 
	qzuriel05.tabajara.intranet" 

ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)
AGR="bitcoin-transaction"
KEY="PROBE"
FILE="/tmp/falha-probe-bitcoin"

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$MSG"

        }

for SRV in `echo $SERVERS`
	do
		RESULT=`curl -s -H 'cache-control: no-cache' -X GET http://$SRV:8080/actuator/health -H 'Postman-Token: d1aed1b2-3f4d-4b2a-8591-4939634ed446' -H 'cache-control: no-cache' | grep -w "UP"`

		if [ `echo $?` != 0 ]
			then
				echo "Falha no probe do Host: $SRV" >> $FILE
		fi
	done

		TTL=`wc -l $FILE | awk '{ print $1 }'`

		if [ $TTL -gt 0 ]
			then
				MSG=`cat $FILE | grep -vF '\'`
				fn_send_zabbix
			else
				MSG="0"
				fn_send_zabbix
		fi
rm $FILE
