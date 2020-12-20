#!/bin/sh

DT=`date +%d-%m-%Y --date="1 days ago"`

WORKDIR="/volume-zabbix/log"
FILELOG="/volume-zabbix/log/zabbix-incidentes.log"

NEWNAME="zabbix-incidentes-${DT}.log"
cp $FILELOG $WORKDIR/$NEWNAME
gzip $WORKDIR/$NEWNAME
:> $FILELOG
systemctl restart rsyslog
