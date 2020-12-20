#!/bin/sh

# Script para monitorar se um ponto de montagem no FSTAB esta carregado no /proc"
# usando o comando mount 

# Author: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Data 22/04/2019

ZBX_CONF="/etc/zabbix/zabbix_agentd.conf"
ZBXSND=$(which zabbix_sender)
KEY="mount_point"

fn_send_zabbix()
  {
  $ZBXSND -c $ZBX_CONF -k $KEY -o "$MSG" 
  }

#MOUNT_LIST=`cat /etc/fstab | egrep -v "^#|swap" | sed 's/\///g' | awk '{ print $2 }' | sort -u`
MOUNT_LIST=`cat /etc/fstab | egrep -v "^#|swap" | awk '{ print $2 }' | rev | cut -f1 -d"/" | rev`

for mount_point in `echo $MOUNT_LIST`
  do
    mount | grep "$mount_point" > /dev/null
    RESULT=`echo $?`

    if [ $RESULT != 0 ]
       then
           MSG="Ponto de montagem $mount_point com falha"
           fn_send_zabbix 
       else
           MSG="$mount_point Ok"
           fn_send_zabbix
    fi
  done
