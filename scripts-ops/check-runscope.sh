#!/bin/bash

API="$1"
#USER="$2"
#PASS="$3"
TOKEN="$2"

# Endpoint do API para verificar o runscope

#API_API="https://api.runscope.com/radar/3212ff9c-aae4-4662-bd04-7d8297f2d62a/trigger"
API_API="https://api.runscope.com/buckets/1b8cgrqhhzdc/tests"

# LOCKFILE
LOCK="/tmp/api-runscope.lck"

# TEMP File

TEMP_FILE="/tmp/db.temp"

## Agente de envio
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d"=" -f2)
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
                        fn_check_status_system_by_runscope
        fi
        }

fn_send_zabbix_api_health()
        {
        $ZBXSND -vv -z $ZBXPRX -s $runscope_test -k API_ERROR_COUNT -o $API_ERROR_COUNT
#        $ZBXSND -vv -z $ZBXPRX -s runscope-api -k API_ERROR_COUNT -o $API_ERROR_COUNT
        }

fn_send_zabbix_api_status()
        {
        $ZBXSND -vv -z $ZBXPRX -s $runscope_test -k API_SUCCESS -o $API_SUCCESS
#        $ZBXSND -vv -z $ZBXPRX -s runscope-api -k API_SUCCESS -o $API_SUCCESS
        }

fn_send_zabbix_api_extractor_success()
        {
        $ZBXSND -vv -z $ZBXPRX -s $runscope_test -k API_EXTRACTOR_SUCCESS -o $API_EXTRACTOR_SUCCESS
#        $ZBXSND -vv -z $ZBXPRX -s runscope-api -k API_EXTRACTOR_SUCCESS -o $API_EXTRACTOR_SUCCESS

        }

fn_check_status_system_by_runscope()
        {
	curl -s -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer 56f0aa56-fab0-4742-84fa-6b3841a4e34d' $API_API  | jq '.' > $TEMP_FILE
		
        runscope_TEST_LIST=`cat $TEMP_FILE | awk ' /test_uuid/ { print $2 }'  | sed -e 's/"//g' -e 's/,//g'`

        for runscope_test in `echo $runscope_TEST_LIST`
                do
                        API_ERROR_COUNT=`cat $TEMP_FILE |  grep $runscope_test -B 3 |grep error | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
                        fn_send_zabbix_api_health

                        API_SUCCESS=`cat $TEMP_FILE |  grep $runscope_test -B 2 |grep success | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
                        fn_send_zabbix_api_status

                        API_EXTRACTOR_SUCCESS=`cat $TEMP_FILE |   grep $runscope_test -A 2 | grep extractor |tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
                        fn_send_zabbix_api_extractor_success


                done
        }

fn_gc()
        {
        rm $LOCK
#        rm $TEMP_FILE
        }

fn_check_lock
fn_gc
