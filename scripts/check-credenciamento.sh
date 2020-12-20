#!/bin/sh

# Script para monitorar o probe do credenciamento.
# medida tomada ate o ajuste do probe no vip
# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br | ambrosia@gmail.com

# Executa um curl com o header igual ao Virtual Host para fazer match
SERVERS="novoportal01.tabajara.local \
	 novoportal02.tabajara.local \
	 novoportal03.tabajara.intranet \
	 novoportal04.tabajara.intranet \
	 novoportal05.tabajara.intranet"

ZBXPRX="zbxprxapp01.tabajara.intranet"
ZBXSND=$(which zabbix_sender)
AGR="credenciamento"
KEY="PROBE"
FILE="/tmp/falha-probe-cred"

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$MSG"

        }

for SRV in `echo $SERVERS`
	do
		RESULT=`curl -s --connect-timeout 5 --header 'Host: credenciamento.tabajara.com.br' http://$SRV/credenciamento-api/health | grep -w  "UP"`

		if [ `echo $?` != 0 ]
			then
				echo "Falha no probe do credenciamento - Host: $SRV" >> $FILE
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
