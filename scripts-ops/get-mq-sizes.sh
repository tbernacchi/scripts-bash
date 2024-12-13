#!/bin/bash

FILETEMP=`mktemp --suffix=-MQ`

ZBXPRX="zbxprxapp01.tabajara.intranet"
ZBXSND=$(which zabbix_sender)

AGR="RabbitMQ-Pool-Zila"

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$VALUE"
        }

fn_get_status()
	{
	IFS=$'\n'

	ordered_vhosts=$(/sbin/rabbitmqctl list_vhosts -q | xargs -n1 | sort -u)

	for V in $ordered_vhosts
		do
    			for Q in $(/sbin/rabbitmqctl list_queues -q name messages -p $V | xargs -n2 | sort -u) 
				do
        				echo "$Q" >> $FILETEMP
    				done
		done
	
	fn_make_send

	}

fn_make_item()
	{
	JSON_AUTH=`mktemp --suffix=-ZABBIX-MQ-AUTH`
	JSON_ITEM=`mktemp --suffix=-ZABBIX-MQ-ITEM`

	# Endpoint do Zabbix
	ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"
	
	# Usuari0 e senha no zabbix e rundeck 
	USER="svc_zabbix_monit"
	PASS="kwf4384R?"

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

# Agora criamos o item
cat > $JSON_ITEM <<END
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "$KEY",
        "key_": "$KEY",
        "hostid": "12150",
        "type": 2,
        "value_type": 3,
	"interfaceid": "1697",
	"applications": [
		"12403"
	],
	"trapper_hosts": ""
    },
    "id": 1,
    "auth": "$COOKIE"
}
END

	# Criando o item
	curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_ITEM $ZABBIX_API
     	sleep 1

	}

fn_make_send()
	{
	for KEY in `cat $FILETEMP | awk '{ print $1 }'`
		do
			VALUE=`cat $FILETEMP | grep $KEY | awk '{ print $2 }'`
	
			fn_make_item
			fn_send_zabbix
		done
	}

fn_gc()
	{
	#rm -f $FILETEMP
	rm -f /tmp/*ZABBIX*
	}

fn_get_status
fn_gc
