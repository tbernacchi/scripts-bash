#!/bin/bash

# Script para obter o status dos jobs do rundeck

TEMPLATE_ID="11964"
TEMPLATE_NAME="Servicos-Core-Jobs-Rundeck"

GRP_ID="148"
GRP_NAME="jobs-rundeck"

JSON_AUTH=`mktemp --suffix=-ZABBIX-JOBS-AUTH`
JSON_HOST=`mktemp --suffix=-ZABBIX-JOBS`

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"
DB_PRJ="/tmp/rundeck-prj.db"

# Usuari0 e senha no zabbix e rundeck 
USER="svc_zabbix_monit"
PASS="kwf4384R?"
ZBXPRX="zbxprx01.tabajara.local"
PRX_ID="10254"

# token no rundeck
TOKEN="V4g8nqqH0ZwKHrZDUGU4GxJV4hJKofM9"

# LOCKFILE
LOCK="/tmp/get-rundeck.lck"

# LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
		echo $$ > $LOCK
    fn_host_create
	fi
	}

fn_send_zabbix()
  {
  ## Agente de envio
  ZBXPRX="zbxprx01.tabajara.local"
  ZBXSND=$(which zabbix_sender)
 
  $ZBXSND -z $ZBXPRX -s job-$JOB -k job_time -o $TIME 
  $ZBXSND -z $ZBXPRX -s job-$JOB -k job_status -o $STATUS 
}


# O corpo do JSON para verificar e salva o COOKIE de autenticacao no Zabbix (usuario svc_zabbix_monit e senha kwf4384R?)

fn_host_create()
	{
cat > $JSON_AUTH <<END
{
	"jsonrpc": "2.0",
	"method": "user.login",
	"params": {
		"user": "$USER",
		"password": "$PASS"
	},
	"id": 1,
	"auth": null
}

END

	# Fazendo o post e salvando o cookie
	COOKIE=`curl -s -i -X POST -H 'Content-Type:application/json' -d@$JSON_AUTH $ZABBIX_API | tail -n1 | cut -f8 -d\"`

	# Lista
	PRJS=`curl -s -H "Accept: application/json" -X GET "http://rundeck.tabajara.intranet/api/1/projects?authtoken=$TOKEN" | jq '.[] | .name' | sed 's/"//g'`

	for prj in `echo $PRJS`
    do
      curl -s -H "Accept: application/json" -X GET "http://rundeck.tabajara.intranet/api/29/project/$prj/executions?authtoken=$TOKEN" |  jq '.executions[] | "\(.job.name) \(.job.averageDuration) \(.status)"' | sed 's/"//g'  >> $DB_PRJ
    done 

  # gera a lista
  for JOB in `cat $DB_PRJ | egrep -vi "deploy|promove" | awk '{ print $1 }' | sort -u`
    do
      MSTIME=`grep $JOB $DB_PRJ | awk '{ print $2 }' | head -n 1`
      TIME=`echo "$MSTIME / 1000" | bc`
      STATUS=`grep $JOB $DB_PRJ | awk '{ print $3 }' | head -n 1`

cat > $JSON_HOST <<END
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "job-$JOB",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "127.0.0.1",
                "dns": "job-$JOB",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": "$GRP_ID"
            }
        ],
        "templates": [
            {
                "templateid": "$TEMPLATE_ID"
            }
        ]
    },
        "id": 1,
        "auth": "$COOKIE"
}
END

      # Criando os hosts no Zabbix
      curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_HOST $ZABBIX_API
      sleep 1

      # como zabbix nao tem criacao com o proxy - update na seq
      WS_UPDATE="http://zabbix.tabajara.local/zabbix-balancer/ws/update-zabbix-proxy.php"

      # Executando o update
      curl --data "proxy_hostid=$PRX_ID&host=job-$JOB" -X POST $WS_UPDATE
      sleep 1

      # envia para o zabbix
      fn_send_zabbix

    done
  }

# clean
fn_gc()
  {
    # Remove os temps
    rm -f /tmp/*-ZABBIX-JOBS*
    rm -f /tmp/rundeck-*
    rm -f $LOCK
  }
# main
fn_check_lock
fn_gc
