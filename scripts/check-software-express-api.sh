#!/bin/bash
# Script para verificar versão e release date da API da Software Express
# https://jiratabajara.atlassian.net/browse/INFRA-724

#API="$1"
#USER="$2"
#PASS="$3"
#TOKEN="$2"

# Informações da API

API_API="https://wspendencia.softwareexpress.com.br:9471"
USER=tabajara
PW=catabajara

# LOCKFILE
LOCK="/tmp/api-soft_express.lck"

# TEMP File
TEMP_VERSION="/tmp/soft_express.temp"

## Agente de envio
#ZBXPRX=`grep ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d"=" -f2`
ZBXPRX=zbxprxapp01.tabajara.intranet

ZBXSND=$(which zabbix_sender)

# Host no Zabbix
soft_express_test=SoftwareExpress_API

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
                        fn_check_version_system_by_soft_express
        fi
        }

fn_send_zabbix_api_version()
        {
        $ZBXSND -vv -z $ZBXPRX -s $soft_express_test -k API_VERSION -o $API_VERSION
        }

#fn_send_zabbix_api_release_date()
#        {
#        $ZBXSND -vv -z $ZBXPRX -s $soft_express_test -k API_RELEASE_DATE -o $API_RELEASE_DATE
#        }


fn_check_version_system_by_soft_express()
        {
        curl -s -X GET -k --user $USER:$PW  $API_API/versao  | jq '.' > $TEMP_VERSION
		API_VERSION=`cat $TEMP_VERSION | awk ' /version/ { print $2 }'  | sed -e 's/"//g' -e 's/,//g'`
#		API_RELEASE_DATE= `cat $TEMP_VERSION | awk ' /version/ { print $3 }'  | sed -e 's/"//g' -e 's/,//g' -e 's/(//g' -e 's/)//g'`
		
        fn_send_zabbix_api_version
        }

fn_check_data_range_by_soft_express()
        {
        curl -s -X GET -k --user $USER:$PW  $API_API/transacoes/buscadata?datatrn=20190101&horainicial=000000&horafinal=000000 | jq '.' > $TEMP_RANGE
        API_RANGE=`cat $TEMP_RANGE | awk ' /status/ { print $3 }'  | sed -e 's/"//g' -e 's/,//g'`
 
#        fn_send_zabbix_api_range
        }  

fn_gc()
        {
        rm $LOCK
#        rm $TEMP_FILE
        }

fn_check_lock
fn_gc

