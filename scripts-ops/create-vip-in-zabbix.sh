#!/bin/bash

# Script para criar os vip no Zabbix

SLB="$1"
USER="$2"
PASS="$3"

TEMPLATE_ID="10801"
TEMPLATE_NAME="SLB_VIP_STATUS"

GRP_ID="85"
GRP_NAME="Serivcos-Core-VIP"

JSON_AUTH_VIP=`mktemp --suffix=-ZABBIX-NEW-VIP-AUTH`
JSON_HOST_VIP=`mktemp --suffix=-ZABBIX-NEW-VIP`

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"
DB_PRJ="/tmp/new-vip.db"

# Usuari0 e senha no zabbix e rundeck 
USER_ZABBIX="svc_zabbix_monit"
PASS_ZABBIX="kwf4384R?"

ZBXPRX="zbxprx01.tabajara.local"
PRX_ID="10254"

## Netscaler
# Endpoint do SLB para verificar por vip
SLB_API_VIP="http://$SLB/nitro/v1/stat/lbvserver"

# Endpoint do SLB para verificar por servicegroup
SLB_API_SG="http://$SLB/nitro/v1/config/lbvserver_binding"

# TEMP File
TEMP_FILE="/tmp/new-db-vip.temp"
# GROUP_FILES
TEMP_SG="/tmp/-new-db-vip.sg"

# LOCKFILE
LOCK="/tmp/get-new-vip.lck"

# LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
		  echo $$ > $LOCK
      #fn_host_create
      fn_get_vip
  fi
	}

fn_host_create()
  {
cat > $JSON_AUTH_VIP <<END
  {
  "jsonrpc": "2.0",
  "method": "user.login",
  "params": {
    "user": "$USER_ZABBIX",
    "password": "$PASS_ZABBIX"
    },
   "id": 1,
   "auth": null
  }
END

  # Fazendo o post e salvando o cookie
  COOKIE=`curl -s -i -X POST -H 'Content-Type:application/json' -d@$JSON_AUTH_VIP $ZABBIX_API | tail -n1 | cut -f8 -d\"`

# Criando o host
cat > $JSON_HOST_VIP <<END
{
  "jsonrpc": "2.0",
  "method": "host.create",
  "params": {
    "host": "$name_vip",
    "interfaces": [
        {
        "type": 1,
        "main": 1,
        "useip": 1,
        "ip": "$ENDIP",
        "dns": "$name_vip",
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
    curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_HOST_VIP $ZABBIX_API
    sleep 1

    # como zabbix nao tem criacao com o proxy - update na seq
    WS_UPDATE="http://zabbix.tabajara.intranet/zabbix-balancer/ws/update-zabbix-proxy.php"

    # Executando o update
    curl --data "proxy_hostid=$PRX_ID&host=$name_vip" -X POST $WS_UPDATE
    sleep 1
}

fn_get_vip()
  {
   curl -s -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API_VIP | grep errorcode  | jq '.lbvserver[] | "\(.name) \(.primaryipaddress)"' | sed -e 's/"//g' -e 's/ /|/g' | sort -u >> $TEMP_FILE

   for name_vip in `cat $TEMP_FILE | awk -F'|' '{ print $1 }' | sort -u`
    do
      ENDIP=`cat $TEMP_FILE | grep -w "$name_vip" | awk -F'|' '{ print $2 }' | sort -u`

      echo "faz o post no zabbix!"
      fn_host_create
    done
  }

# clean
fn_gc()
  {
    # Remove os temps
    rm -f /tmp/*NEW-VIP*
    rm -f $TEMP_FILE
    rm -f $LOCK
  }
# main
fn_check_lock
fn_gc
