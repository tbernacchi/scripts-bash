#!/bin/bash

# Script para verificar as triggers alarmadas no Zabbix e abrir uma request (incidente) no Zabbix
# Autor: Ambrosia Ambrosiano
# data: 23/02/2018

# Funcionamento basicao usando os metodos das API do Zabbix e Jira SD em:
# Zabbix: https://www.zabbix.com/documentation/3.0
# Jira SD: https://docs.atlassian.com/jira-servicedesk/REST/3.9.1

# Problema/deficiencia: a API do Jira SD, nao contempla (ou eh pouco documentada) o fechamento de uma request (incidente) via API
# existem relatos desse problema na lista de suporte da comunidade de utilizadores do sistema

# Este script foi feito em Shell Script, pois dois motivos:
# Ser feito rapidamente e permitir uma futura migracao para outra liguagem mais moderna (Python)

# Regras:
# 1 - pegar todos as triggers alarmadas no Zabbix, criar uma lista e salvar em diretorio para posterior consulta
# 2 - separar a lista por triggers alarmadas
# 3 - abrir uma nova request do tipo incidente no Jira Service Desk

# Mandatorio: verificar se trigger alarmada ja possuei uma request aberta no Jira e nao abrir em duplicidade

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
mktemp --suffix=-ZABBIX
JSON=`mktemp --suffix=-ZABBIX`
JSON_AUTH=`mktemp --suffix=-ZABBIX`
JSON_SD=`mktemp --suffix=-ZABBIX`
JSON_TRIGGERS=`mktemp --suffix=-ZABBIX`
JSON_UNIQ=`mktemp --suffix=-ZABBIX`
JSON_DONE=`mktemp --suffix=-ZABBIX`
JSON_CLOSE=`mktemp --suffix=-ZABBIX`
JSON_SLACK=`mktemp --suffix=-ZABBIX`

# Diretorio de trabalho para armazenar as triggers
WORKDIR="/volume-zabbix/integracao-zabbix-sd"
#WORKDIR="/var/integracao-zabbix-sd"

# Arquivo de controle para base de consulta dentro do fluxo
ALARM_TRIGGER="$WORKDIR/trigger.zbx"

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

# Endpoint do Jira
JIRA_API="https://sd-tabajara.atlassian.net/rest/servicedeskapi/request"

# Endpoint do canal do slack sd-noc-tabajara
SLACK_NOC_API="https://hooks.slack.com/services/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"

# Usuari0 e senha no zabbix e jira
USER="svc_zabbix_monit"
PASS="kwf4384R?"

# file trigger
TRG_FILE="trigger-alarme"


# LOCKFILE
#LOCK="/tmp/integrazbxjira.lck"
LOCK="/volume-zabbix/lock/integrazbxjira.lck"

### LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
			echo $$ > $LOCK
	fi
	}



# O corpo do JSON para verificar e salva o COOKIE de autenticacao no Zabbix (usuario svc_zabbix_monit e senha kwf4384R?)

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

# Funcao para capturar os status das Triggers salvando em um unico arquivo a lista
fn_get_triggers()
	{
cat > $JSON_TRIGGERS <<END
{
	"jsonrpc": "2.0",
	"method": "trigger.get",
	"params": {
		"output": [
			"triggerid",
			"description",
			"priority"
	],
	"filter": {
		"value": 1
	},
	"sortfield": "priority",
	"sortorder": "DESC"
	},
	"id": 1,
	"auth": "$COOKIE"
}
END


# Gerando a lista de trigger alarmadas no Zabbix
	curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_TRIGGERS $ZABBIX_API | grep jsonrpc > $ALARM_TRIGGER
	sleep .5
	}

# Funcao para separar as triggers
fn_separa_triggers()
	{
	ID_TRIGGER=`cat $ALARM_TRIGGER | jq '.' | grep triggerid | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
	for id_trigger in `echo $ID_TRIGGER`
		do
			ls $WORKDIR | grep $id_trigger

cat > $JSON_UNIQ <<END
{
	"jsonrpc": "2.0",
	"method": "trigger.get",
	"params": {
		"triggerids": "$id_trigger",
		"sortfield": "hostname",
		"expandData": 1,
		"expandDescription": 1,
		"output": "extend",
		"monitored": 1,
		"only_true": 1,
		"skipDependent": 1,
		"active": 1,
		"expandExpression": 1
		},
	"auth": "$COOKIE",
	"id": 1
}
END
			curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_UNIQ $ZABBIX_API > $WORKDIR/$TRG_FILE-$id_trigger
			sleep .5
		done
	}

# Funcao para verificar o arquivo similar que ainda existe no diretorio e fechar o IM se nao tiver mais alarmando
fn_check_close_im()
	{

	STATUS=`curl -u $USER@tabajara.com.br:$PASS -i -X GET -H 'Content-Type: application/json' $JIRA_API/$ISSUE/status | grep size | jq ".values" | grep -w status | awk '{ print $2 }' | cut -f1 -d"," | sed 's/"//g'`
	sleep .5

	echo "Status do IM $ISSUE : $EXIST_IM"

	if [ "$STATUS" != "Open" ]
		then
			echo "Incidente nao esta aberto, nao preciso fechar entao"
		else
			echo "O incidente aberto tenho que fechar - $ISSUE - Status $IM"

DT=`date +%d-%m-%Y--%H:%M:%S`

# JSON para DONE
cat > $JSON_DONE <<END
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "Encerrado pelo Zabbix - $DT"
                }
            }
        ]
    },
    "fields": {
        "resolution": {
            "name": "Done"
        }
    },
    "transition": {
        "id": "111"
    }
}
END

# JSON para CLOSE
cat > $JSON_CLOSE <<END
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "Fechado pelo Zabbix - $DT"
                }
            }
        ]
    },
    "transition": {
        "id": "91"
    }
}
END

	# Executando o DONE
	curl -v -u 'svc_zabbix_monit@tabajara.com.br:kwf4384R?' -i -X POST -H 'Content-Type: application/json' -d@$JSON_DONE https://sd-tabajara.atlassian.net/rest/api/2/issue/$ISSUE/transitions
	sleep .5

	# Executando o CLOSE
	curl -v -u 'svc_zabbix_monit@tabajara.com.br:kwf4384R?' -i -X POST -H 'Content-Type: application/json' -d@$JSON_CLOSE https://sd-tabajara.atlassian.net/rest/api/2/issue/$ISSUE/transitions
	sleep .5

	fi
	}

# Funcao que verifica o status do similar para fechar o incidente no Jira - dessa forma nao ficamos consultando os incidentes online
fn_clean_geral()
	{
	 for DESCR in `ls $WORKDIR | grep description`
		do
			TRIGGER_ID=`cat $WORKDIR/$DESCR | grep jsonrpc | jq -r ."result" | grep triggerid | awk '{ print $2 }' | sed 's/"//g' | cut -f1 -d"," `
			ISSUE=`cat $WORKDIR/$DESCR |  grep expands | jq ."issueKey" | sed 's/"//g'`

			cat $ALARM_TRIGGER | grep $TRIGGER_ID > /dev/null

			if [ `echo $?` != 0 ]
				then
					echo "Nao esta alarmando agora, devemos fechar o incidente"
					fn_check_close_im
					rm $WORKDIR/$DESCR
			fi
		done
	}

# Funcao de abertura de incidente
# Agora criamos o corpo e abertura do incidente no Jira
fn_exec_open_incidente()
        {

	# Ajustando a prioridade
	PRIO_ZBX=`cat $WORKDIR/$FILE_DESCRIPTION.description  | grep -w "jsonrpc" | jq -r '.' | grep -w "priority" | awk '{ print $2 }' | sed 's/"//g' | cut -f1 -d","`

	case $PRIO_ZBX in
		0)
			PRIO_SD="Em_validacao"
			COD_PRIO="5"
		;;
		1)
			PRIO_SD="INFO"
			COD_PRIO="5"
		;;

		2)
			PRIO_SD="P4"
			COD_PRIO="4"
		;;

		3)
			PRIO_SD="P3"
			COD_PRIO="3"
		;;

		4)
			PRIO_SD="P2"
			COD_PRIO="2"
		;;

		5)
			PRIO_SD="P1"
			COD_PRIO="1"
		;;
	esac

        # preparando o corpo
        TRIGGER_ID=`cat $WORKDIR/$FILE_DESCRIPTION.description | grep -w "jsonrpc" | jq -r '.' | grep -w "triggerid" | sed 's/"//g'`
        CI=`cat $WORKDIR/$FILE_DESCRIPTION.description | grep -w "jsonrpc" | jq -r '.' | grep -w "hostname" | sed 's/"//g'`
        DESCRIPTION=`cat $WORKDIR/$FILE_DESCRIPTION.description | grep -w "jsonrpc" | jq -r '.' | grep -w "description"| sed 's/"//g'`
        URL=`cat $WORKDIR/$FILE_DESCRIPTION.description | grep -w "jsonrpc" | jq -r '.' | grep -w "url" | sed 's/"//g' | cut -f1 -d","`
      	DT=`date +%d-%m-%Y--%H:%M:%S`

        echo "trigger: $TRIGGER_ID"
        echo "hostname: $CI"
        echo "description: $PRIO_SD - $DESCRIPTION"
        echo "url: $URL"
	      echo "Data: $DT"

cat > $JSON_SD <<END
{
        "serviceDeskId": "1",
        "requestTypeId": "100",
        "requestFieldValues": {
        	"summary": "$PRIO_SD - $CI - $DESCRIPTION",
                	"description": "$DT \n $CI \n $DESCRIPTION \n $URL \n $TRIGGER_ID",
			"priority": {
				"id": "$COD_PRIO"
			}
			
        },
        "requestParticipants": [
                "$USER"
        ]
}
END

# JSSON para Slack

echo "$PRIO_SD $CI $DESCRIPTION $URL"

cat > $JSON_SLACK <<END
{
  "channel": "#sd-noc-tabajara",
  "username": "webhookbot",
  "text": "$PRIO_SD $CI $DESCRIPTION $URL",
  "icon_emoji": ":biohazard_sign:"
}
END

echo $PRIO_SD
	if [ $COD_PRIO = 5 ]
		then
			echo "so info ou validacao - nao abre incidente"
		else
			curl -v -u $USER@tabajara.com.br:$PASS -i -X POST -H 'Content-Type: application/json' -d@$JSON_SD $JIRA_API >> $WORKDIR/$FILE_DESCRIPTION.description
			echo "Se chegou era novo $trigger"
      
      # mando para o slack
      curl -X POST -H 'Content-Type: data-urlencode' -d@$JSON_SLACK $SLACK_NOC_API

      # damos um folego
			sleep .5
	fi
        }

# Funcao para remover sujeira e criar o arquivo para comparar o similar
fn_sanatizar()
	{
	# Verificando quais arquivos nao tem trigger
	for lst_sem_trigger in `ls $WORKDIR | grep $TRG_FILE`
		do
			grep trigger $WORKDIR/$lst_sem_trigger > /dev/null

			if [ `echo $?` != 0 ]
				then
					echo "$lst_sem_trigger nao tem trigger"
					rm $WORKDIR/$lst_sem_trigger
			fi
		done

	# Para cada trriger com alarme gerando um arquivo para verificar a similaridade e usar como base de consulta para evitar duplicidade

	for trigger in `ls $WORKDIR | grep $TRG_FILE`
		do
			FILE_DESCRIPTION=`cat $WORKDIR/$trigger | grep jsonrpc | jq -r '.' | grep -w expression | awk '{ print $2 }' | sed 's/"//g' | cut -f2 -d"{" | sed -e 's/://g' -e 's/\[//g' -e 's/\]//g' -e 's/\///g' -e 's/,//g' -e 's/(//g' -e 's/)//g' -e 's/{//g' -e 's/}//g' -e 's/>//g' -e 's/<//g' -e 's/\=//g' -e 's/\#//g' -e 's/\%//g' -e 's/-//g'`

			test -e $WORKDIR/$FILE_DESCRIPTION.description

			if [ `echo $?` == 0 ] 
				then
					echo "Ja tem arquivo no diretorio"
					rm $WORKDIR/$trigger
				else
					echo "Nao tem arquivo no diretorio - Open"
					mv $WORKDIR/$trigger $WORKDIR/$FILE_DESCRIPTION.description
					fn_exec_open_incidente
			fi
		done

	}

# GC
fn_clean_all()
	{
	rm $LOCK
	rm /tmp/tmp*-ZABBIX
	}

# Executa as funcoes na ordem
fn_check_lock
fn_get_triggers
fn_separa_triggers
fn_clean_geral
fn_sanatizar
fn_clean_all

