#!/bin/bash


# Script que monitora os VIPS e seus status
# Obtem a lista de VIPs criadas nos SLB e retorna a saude o trafego de cada um
# enviando o status para o Zabbix via zabbix trapper

# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br ambrosia@gmail.com

# Adicionada a funcao de cadastro automatico de VIP no Zabbix 
# dessa forma a partir do momento que um novo VIP eh criado o 
# Zabbix passa a monitora-lo

SLB="$1"
USER="$2"
PASS="$3"

# Endpoint do SLB para verificar por vip
SLB_API="http://$SLB/nitro/v1/stat/lbvserver"

# LOCKFILE
LOCK="/tmp/slb-vip.lck"

# TEMP File
TEMP_FILE="/tmp/db.temp"

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

## Itens para o cadastro do "host" no Zabbix
JSON=`mktemp --suffix=-ZABBIX`
JSON_AUTH=`mktemp --suffix=-ZABBIX`
JSON_HOST=`mktemp --suffix=-ZABBIX`

# EndPoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.local/zabbix/api_jsonrpc.php"

# Usuario e senha no Zabbix
USER="svc_zabbix_monit"
PASS="kwf4384R?"

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'


# Criando o body para o Auth no Zabbix

cat > $JSON_AUTH <<END
{
	"jsonrpc": "2.0"
	"method": "user.login",
	"params": {
		"user": "$USER",
	"password": "$PASS"
	},
	"id": ',
	"auth": null
}

END

# Fazendo o post e salvando o cookie
COOKIE=`curl -s -i -X POST -H 'Content-Type:application/json' -d@$JSON_AUTH $ZABBIX_API | tail -n1 | cut -f8 -d\"`

fn_cria_vip_zabbix()
	{

# Criando o body

cat > $JSON_HOST <<END
{

}
END
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
			fn_check_status_system_by_vip
	fi
	}

fn_send_zabbix_slb_health()
        {
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_HEALTH -o $SLB_HEALTH
        }

fn_send_zabbix_slb_status()
        {
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_STATUS -o $SLB_STATUS
        }

fn_send_zabbix_slb_rate_reqs_bytes()
	{
        $ZBXSND -z $ZBXPRX -s $vip_name -k SLB_RATE_REQS_BYTES -o $SLB_RATE_REQS_BYTES
	}

fn_check_status_system_by_vip()
	{
	curl -s -u $USER:$PASS -i -X GET -H 'Content-Type: application/json' $SLB_API | grep errorcode | jq . > $TEMP_FILE

	VIP_NAMES=`cat $TEMP_FILE | egrep -w "name" | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`

	for vip_name in `echo $VIP_NAMES`
		do
			SLB_HEALTH=`cat $TEMP_FILE | grep $vip_name -A5 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_health

			SLB_STATUS=`cat $TEMP_FILE | grep $vip_name -A9 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_status

			SLB_RATE_REQS_BYTES=`cat $TEMP_FILE | grep $vip_name -A18 | tail -n1 | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
			fn_send_zabbix_slb_rate_reqs_bytes


		done
	}


fn_gc()
	{
	rm $LOCK
	rm $TEMP_FILE
	}

fn_check_lock
fn_gc

