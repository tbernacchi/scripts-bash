#!/bin/bash

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, .tabajara.intranet, 10.0.0.0/8'

# Variaveis para armazenar o JSON que sera utilizado no post do Zabbix, nao precisa de maiores controles, pois sera sobrescrito
JSON_AUTH=`mktemp --suffix=-HST`
JSON_HOSTS=`mktemp --suffix=-HST`
JSON_ITEM=`mktemp --suffix=-HST`

# Diretorio de trabalho para armazenar as triggers
WORKDIR="/volume-zabbix/zabbix-stale"

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

# Usuari0 e senha no zabbix e jira
USER="svc_zabbix_monit"
PASS="kwf4384R?"

# Arquivos
HOST_LIST="/volume-zabbix/zabbix-stale/hosts-list"
ITEM_LIST="/volume-zabbix/zabbix-stale/items-list"

# Intervalo limite
# minutos
#LIMIT="86400" # 24h
LIMIT="43200" # 12h
#LIMIT="90" # 1h30m

# Para enviar os itens
ZBXSND=$(which zabbix_sender)
KEY="stale"
FILECONSUL="/var/www/html/zabbix-balancer/zabbix-balancer-list-client"

# LOCK
LOCK="/tmp/lock-stale"

### LOCK
fn_check_lock()
        {
        # feio, mas ta ok
        rm -f `find  /tmp/lock-stale -cmin +180`

        if [ -e $LOCK ]
                then
                        echo "Arquivo de lock $LOCK encontrado, saindo..."
                        exit 0
                else
                        echo $$ > $LOCK
        fi
        }


fn_send_zabbix()
	{
	$ZBXSND -z $ZBXPRX -s $CLIENT -k $KEY -o "$MSG"
	}

fn_zabbix_get()
	{
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

# Obtendo a lista de hosts

cat > $JSON_HOSTS <<END
{
	"jsonrpc": "2.0",
	"method": "host.get",
	"params": {
		"output": "extend",
		"monitored": 0
	},
	"auth": "$COOKIE",
	"id": 1
}
END

# Executando o teste:

curl -s -i -X POST -H 'Content-Type:application/json' -d@$JSON_HOSTS $ZABBIX_API | grep jsonrpc | jq . > $HOST_LIST

# Agora obtemos os ID dos hosts para consultar os itens

HOSTIDS=`cat $HOST_LIST | grep -w "hostid" | awk '{ print $2 }' | cut -f2 -d"\""`

for hostid in `echo $HOSTIDS`
	do

	#sleep 2 

cat > $JSON_ITEM << END
{
	"jsonrpc":"2.0",
	"method":"item.get",
	"params":{
		"output":"extend",
		"filter":{
			"hostid":"$hostid"
		}
	},
	"auth":"$COOKIE",
	"id": 1
}

END

		curl -v -i -X POST -H 'Content-Type:application/json' -d@$JSON_ITEM $ZABBIX_API | grep jsonrpc | jq . > $ITEM_LIST-$hostid

		for itemid in `cat $ITEM_LIST-$hostid | grep -w "itemid" | cut -f4 -d"\""`
			do
				#sleep 2 

				HOSTID=`ls $ITEM_LIST-$hostid | cut -f5 -d"-"`
				NAMEHOST=`cat $HOST_LIST | grep $HOSTID -A2 | tail -n1 | cut -f4 -d"\""`

				NAME=`cat $ITEM_LIST-$hostid | grep -w $itemid -A 5 | tail -n1 | cut -f4 -d"\""`
				LCLOCK=`cat $ITEM_LIST-$hostid | grep -w $itemid -A 45 | tail -n1 | cut -f4 -d"\""`

				DTNOW=`date +%s`

				DIF=`echo "$DTNOW - $LCLOCK" | bc`
				DIFM=`echo "$DIF / 60" | bc`

				MAX=`echo "$LIMIT * 60" | bc`

				# Obtendo items para envio: proxy
				# Variavel NAMEHOST eh zerada
				TST_VAR=`test -z $NAMEHOST`

				if [ `echo $?` == 1 ]
					then
						if [ $DIF -gt $MAX ]
							then
                RES_STR=`echo $NAME | grep -c [a-z,A-Z]`

								if [ $RES_STR -gt 0 ]
									then
										echo "Alert - $NAMEHOST item $NAME nao recebe dado a $DIFM minutos" >> $WORKDIR/MSG-$NAMEHOST.log
								fi
						fi
				fi
			done

	done
	}

fn_make_list()
	{
	# Gerando a lista para enviar para o Zabbix
	for FILE_MSG in `ls $WORKDIR | grep "MSG-"`
		do
			NEW=`echo $FILE_MSG | sed 's/MSG-/SND-/g'`

			cat $WORKDIR/$FILE_MSG | egrep -v "stale" >> $WORKDIR/$NEW
		done
	}

fn_send_alert()
	{
	# Enviando para o zabbix de acordo com o proxy do client
	CLIENTS=`cat $FILECONSUL | cut -f1 -d"," | sort -u`

	for CLIENT in `echo $CLIENTS`
		do
			ZBXPRX=`cat $FILECONSUL | grep "^$CLIENT" | cut -f2 -d"," | cut -f2 -d":"`

      # Para tratar algumas excessoes
      cd $WORKDIR
      LISTDEL=`egrep '},|Bacula Job|zulo0[1234].tabajara.intranet item Thread pool|zulo0[1234].tabajara.intranet item Index|zulo0[1234].tabajara.intranet item Elasticsearch cluster|zulo0[1234].tabajara.intranet item JVM mem pools' -l SND-*`

      for listdel in `echo $LISTDEL`
        do
          rm -f $listdel
        done

			# Na seq testamos o status do item e notificamos

			ls $WORKDIR | grep SND | grep $CLIENT > /dev/null

			result=`echo $?`

			if [ $result == 0 ]
				then
					MSG=`cat $WORKDIR/SND-$CLIENT.log`
					fn_send_zabbix
				else
					MSG="0"
					fn_send_zabbix
			fi
		done
	}

fn_gc()
	{
	rm -f /volume-zabbix/zabbix-stale/*
	rm -f /tmp/*-HST
	rm -f /tmp/lock-stale
	}

fn_gc_sem_lock()
	{
	rm -f /volume-zabbix/zabbix-stale/*
	rm -f /tmp/*-HST
	}


#fn_gc_sem_lock
fn_check_lock
fn_zabbix_get
fn_make_list
fn_send_alert
fn_gc
