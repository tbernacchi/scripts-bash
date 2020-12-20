#!/bin/bash

# Documentacao das APIs:

## Jira Sd:
#  https://developer.atlassian.com/cloud/jira/service-desk/jira-rest-api-basic-authentication/
#  https://developer.atlassian.com/cloud/jira/platform/rest/

## Zabbix:
# https://www.zabbix.com/documentation/3.4/manual/api
# Lista de variaveis e funcoes:

#################

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, .tabajara.intranet, 10.0.0.0/8'

# Variaveis para armazenar o JSON que sera utilizado no post do Zabbix, nao precisa de maiores controles, pois sera sobrescrito

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

# Endpoint do Jira
JIRA_API="https://sd-tabajara.atlassian.net/rest/servicedeskapi/servicedesk/1/queue/5/issue"

# Usuari0 e senha no zabbix e jira
USER="svc_zabbix_monit"
PASS="kwf4384R?"

# Token Jira
TOKEN_SD="xEQD5hHyy0hEUBrqJvXN2616"

# LOCKFILE
LOCK="/volume-zabbix/lock/integra-callcenter-zabbix.lck"

fn_send_zabbix()
  {
  ## Agente de envio
  ZBXPRX="zbxprx01.tabajara.local"
  ZBXSND=$(which zabbix_sender)

  $ZBXSND -z $ZBXPRX -s CALLCENTER_TABAJARA -k CALLCENTER-CHAMADO-ABERTO -o "$MSG"
  }


### LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
			echo $$ > $LOCK
      fn_get_callcenter_jirasd
	fi
	}

fn_get_callcenter_jirasd()
  {
  # Obtendo o dado no Jira SD em busca de request aberta pelo Callcenter
  KEY_SD=`curl -s -D- -u svc_zabbix_monit@tabajara.com.br:xEQD5hHyy0hEUBrqJvXN2616 -i -X GET -H 'Content-Type: application/json' $JIRA_API | grep size | jq '.values[] | select(.fields.summary=="Indisponibilidade Sistemas tabajara")' | jq .key`

  test -z $KEY_SD
  RESULT=$?

  if [ $RESULT != 0 ]
    then
      TMP="https://sd-tabajara.atlassian.net/projects/STEL/queues/custom/5/$KEY_SD"
      MSG=`echo $TMP | sed 's/"//g'`
      fn_send_zabbix
    else
      MSG="0"
      fn_send_zabbix
  fi
  }

fn_gc()
  {
  rm -f $LOCK
}

fn_check_lock
fn_gc
