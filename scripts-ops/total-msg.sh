#!/bin/bash
#

### Variaveis

# Variaveis de tempo
DT=`date +%Y-%m-%d`

# LOG FORMAT: sms-mail-dispatcher.log.2018-04-24
LOG="/opt/app/logs/sms-mail-dispatcher.log.$DT"

LOCK="/tmp/total-sms.pid"
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

TT_DIA_SMS=`cat $LOG | grep "sms enviado com sucesso"| wc -l`
$ZBXSND -c $ZBXCONF -k tt_dia_sms -o $TT_DIA_SMS

TT_DIA_MAIL=`cat $LOG | grep -w "email enviado com sucesso" | wc -l`
$ZBXSND -c $ZBXCONF -k tt_dia_mail -o $TT_DIA_MAIL

## Remove LOCK
/bin/rm $LOCK
