#!/bin/sh

WORKDIR="/volume-zabbix/integracao-zabbix-sd"

LOGFILE="/volume-zabbix/log/zabbix-incidentes.log"

DT=`date "+%d-%m-%Y %H:%M:%S"`
SRV=`hostname -f`
##

cd $WORKDIR

FILES=`find . -type f -cmin -2 -name "*.description" | grep -v Cannot`

for file in `echo $FILES`
  do
    VALUES=`cat $file | grep expands | jq '.requestFieldValues' | grep value | head -n1`
    echo "$DT $VALUES" >> $LOGFILE
  done 
