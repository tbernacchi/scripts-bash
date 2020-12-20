#!/bin/bash

#API="$1"
#USER="$2"
#PASS="$3"
#TOKEN="$2"

# Endpoint do API para verificar o pingdom checks

API_API="https://api.pingdom.com/api/2.1/checks"

# LOCKFILE
LOCK="/tmp/api-pingdom.lck"

# TEMP File
TEMP_FILE="/tmp/dbpingdom.temp"

## Agente de envio
#ZBXPRX="zbxprx04.tabajara.intranet"
ZBXPRX=`grep ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d"=" -f2`
#ZBXPRX="zbxsrv01-homolog.tabajara.local"
#ZBXPRX=localhost
ZBXSND=$(which zabbix_sender)

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'

### LOCK
fn_check_lock()
        {
        if [ -e $LOCK ]
                then
                        echo "Arquivo de lock $LOCK encontrado, saindo..."
                        exit 0
                else
                        echo $$ > $LOCK
                        fn_check_status_system_by_pingdom
        fi
        }

fn_send_zabbix_api_responsetime()
        {
        $ZBXSND -vv -z $ZBXPRX -s $pingdom_test -k API_RESPONSE_TIME -o $API_RESPONSE_TIME
#        $ZBXSND -vv -z $ZBXPRX -s pingdom-api -k API_RESPONSE_TIME -o $API_RESPONSE_TIME
        }

fn_send_zabbix_api_status()
        {
        $ZBXSND -vv -z $ZBXPRX -s $pingdom_test -k API_STATUS -o $API_STATUS
#        $ZBXSND -vv -z $ZBXPRX -s pingdom-api -k API_STATUS -o $API_STATUS
        }



fn_check_status_system_by_pingdom()
        {
	curl -s -X GET -H 'Content-Type: application/json' -H 'App-key: uvw9zcmomc0c3a0akf1j61pwycwa6t4b' -H 'Cache-Control: no-cache' -H 'Authorization: Basic aW5mcmFlc3RydXR1cmFAc3RlbG8uY29tLmJyOlN0ZWxvQDIwMTc=' $API_API  | jq '.' > $TEMP_FILE
		
        pingdom_TEST_LIST=`cat $TEMP_FILE | awk ' /hostname/ { print $2 }'  | sed -e 's/"//g' -e 's/,//g'`

        for pingdom_test in `echo $pingdom_TEST_LIST`
                do
                        API_RESPONSE_TIME=`cat $TEMP_FILE |  grep $pingdom_test -B 7 |grep lastresponsetime | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
                        fn_send_zabbix_api_responsetime

                        API_STATUS=`cat $TEMP_FILE |  grep $pingdom_test -B 8 | grep status | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
                        fn_send_zabbix_api_status



                done
        }

fn_gc()
        {
        rm $LOCK
#        rm $TEMP_FILE
        }

fn_check_lock
fn_gc
