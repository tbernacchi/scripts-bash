#!/bin/bash
#

### Variaveis

# Variaveis de tempo
DT=`date +%Y-%m-%d`

# LOG FORMAT: sms-mail-dispatcher.log.2018-04-24
LOG="/opt/app/logs/sms-mail-dispatcher.log.$DT"

## BYTEDB
BYTEDB="/var/db/sms.db"
## PID
LOCK="/tmp/seek-sms.pid"
################################

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)
ZBXCONF="/etc/zabbix/zabbix_agentd.conf"

SRVNAME=`hostname -s`

## Valida/cria LOCK
if [ -f $LOCK  ]; then
        exit 1
else
        /bin/touch $LOCK
fi

## Valida se o arquivo eh novo
ATUAL=$(ls -l $LOG | awk '{print $6}')
ULTIMO=$(cat $BYTEDB)
if [ $ULTIMO -gt $ATUAL ]; then
        echo "0" > $BYTEDB
fi

## Le o log iniciando no SEEKDB
SEEK=$(cat $BYTEDB)

tail -c +$SEEK $LOG > /tmp/lixo.log


## grava o seek
NOVOSEEK=$(echo "$ATUAL" > $BYTEDB)


for tt_sms in `cat /tmp/lixo.log | grep "sms enviado com sucesso" | wc -l`
        do
                 $ZBXSND -c $ZBXCONF -k tt_sms -o $tt_sms
        done


for tt_mail in `cat /tmp/lixo.log |  grep "email enviado com sucesso" | wc -l`
	do
		$ZBXSND -c $ZBXCONF -k tt_mail -o $tt_mail
	done

## Remove LOCK
/bin/rm $LOCK
