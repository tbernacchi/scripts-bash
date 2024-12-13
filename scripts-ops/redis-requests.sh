#!/bin/sh

FILE_LOG="/tmp/redis-log.tmp"


SRVS="quintal01.tabajara.intranet \
      quintal02.tabajara.intranet \
      quintal03.tabajara.intranet \
      quintal04.tabajara.intranet \
      quintal05.tabajara.intranet \
      quintal06.tabajara.intranet"

## Agente de envio
ZBXSND=$(which zabbix_sender)

fn_send_zabbix()
  {
   $ZBXSND -z $ZBX_PROXY -s $srv -k $KEY -o $VALUE
  }

fn_exec_reqs()
  {
  for srv in `echo $SRVS`
  do
    redis-benchmark -h $srv -p 6379 -c 100 -n 1000 -q --csv | sed -e 's/"//g' -e 's/ (/./g' -e 's/)//g' -e 's/ /./g' > $FILE_LOG-$srv

    while IFS= read -r line
    do
      KEY=`echo $line | awk -F',' '{ print $1 }'`
      VALUE=`echo $line | awk -F',' '{ print $2 }'`

      ZBX_PROXY=`curl -s http://zabbix.tabajara.local/zabbix-balancer/zabbix-balancer-list-client | grep ^$srv | awk -F":" '{ print $2 }' | cut -f1 -d","`

      fn_send_zabbix

      done <  $FILE_LOG-$srv

      sleep 30
  done
  }

fn_exec_reqs
