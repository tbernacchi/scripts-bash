#!/bin/sh

# Script para gerar graficos do uso de backup no ambiente
# O bacula nao possui nativamente uma forma mais direta de obter estes dados
# Pegamos os valores (nome e total em Bytes) e enviamos para o Splunk

# Autor: Ambrosia Ambrosiano
# Data: 02/07/2018
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com

# dt: 02/07/2019 
# Alterando para criar o host no zabbix e enviar o dado para gerar alarme quando o crescimento
# perc for maior que um valor pre-determinado

# Comandos basico
# echo "list jobtotals" | bconsole | grep "|" | sed 's/|//g' | grep -v "Bytes" | awk '{ print $4";"$3 }'

# Variaveis

FILETMP="/tmp/ttbkps.log"
FILELNOK="/tmp/ttlnok.log"

LOCK="/tmp/bacula.lock"

TEMPLATE_ID="12746"
TEMPLATE_NAME="STL-Backup-status"

GRP_ID="167"
GRP_NAME="bacula-clientes"

JSON_AUTH=`mktemp --suffix=-ZABBIX-BKP-AUTH`
JSON_HOST=`mktemp --suffix=-ZABBIX-BKP`

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

# Usuari0 e senha no zabbix e rundeck 
USER="svc_zabbix_monit"
PASS="kwf4384R?"
ZBXPRX="zbxprx01.tabajara.local"
PRX_ID="10254"


### LOCK
fn_check_lock()
        {
        if [ -e $LOCK ]
                then
                        echo "Arquivo de lock $LOCK encontrado, saindo..."
                        exit 0
                else
                        echo $$ > $LOCK
			fn_get_send_info
        fi
        }
fn_send_zabbix()
  	{
  	## Agente de envio
  	ZBXPRX="zbxprx01.tabajara.local"
  	ZBXSND=$(which zabbix_sender)

  	$ZBXSND -z $ZBXPRX -s bkp-$BKP_NAME -k bkp-size -o "$GB_USED"
 	}



fn_get_send_info()
	{
	# Obtendo a lista de backups e seus tamanhos 
	echo "list jobtotals" | bconsole | grep "|" | sed 's/|//g' | grep -v "Bytes" | awk '{ print $4";"$3 }' > $FILETMP

	# Pegamos so as linhas corretas
	cat $FILETMP | grep -v "^;" > $FILELNOK


	# Adicionando o total
	cat $FILETMP| grep "^;" | sed 's/;/TT_BKP;/g' >> $FILELNOK

	# Preparando o envio:
	for values in `cat $FILELNOK | grep -v "TT_BKP"`
		do 
			BKP_NAME=`echo $values | cut -f1 -d";"`
			TTBKP=`echo $values | cut -f2 -d";" | sed 's/,//g'`
			GB_USED=`echo "(($TTBKP / 1024) / 1024) / 1024" | bc`
		
			# invoca a criacao do host	
			fn_host_create
		done
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

cat > $JSON_HOST <<END
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "bkp-$BKP_NAME",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "127.0.0.1",
                "dns": "bkp-$BKP_NAME",
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
      curl --data "proxy_hostid=$PRX_ID&host=bkp-$BKP_NAME" -X POST $WS_UPDATE
      sleep 1

      # envia para o zabbix
      fn_send_zabbix
  }



fn_gc()
	{
	rm $FILETMP
	rm $FILELNOK
	rm $LOCK
	}

# main
fn_check_lock
fn_gc
