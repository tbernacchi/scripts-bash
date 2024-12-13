#!/bin/bash

# Script para obter e sumarizar o total de cliente por proxy do Zabbix
# gerar uma lista equalizada de clientes por proxy que sera entregue ao
# servidor via chef-client que executara a baixa da conf (variavel)
# update no DB do Zabbix via API e reinicio do zabbix-agent

## Zabbix:
# https://www.zabbix.com/documentation/3.4/manual/api
# Lista de variaveis e funcoes:

#################

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, .tabajara.intranet, 10.0.0.0/8'

# Variaveis para armazenar o JSON que sera utilizado no post do Zabbix, nao precisa de maiores controles, pois sera sobrescrito
JSON_AUTH=`mktemp --suffix=-zbx-balancer`
JSON_PROXY=`mktemp --suffix=-zbx-balancer`
JSON_CLIENT=`mktemp --suffix=-zbx-balancer`
JSON_MASS_UP=`mktemp --suffix=-zbx-balancer`


# Diretorio de trabalho para armazenar as triggers
WORKDIR="/volume-zabbix/zabbix-balancer"

# Endpoint do Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

# Usuari0 e senha no zabbix e jira
USER="svc_zabbix_monit"
PASS="kwf4384R?"

# Arquivos temporarios
REL_PROXY="$WORKDIR/relacao-proxy-list"
REL_CLIENT="$WORKDIR/relacao-client-list"
REL_TOTAL="$WORKDIR/relacao-total"
CLIENTS_PROXY="$WORKDIR/relacao-by-proxy"
PROXY_FINAL="$WORKDIR/proxy-final"
FINAL_PAGE="$WORKDIR/zabbix-balancer-list-client"
LIST_PROXIES="$WORKDIR/relacao-proxies"
FILE_PASTE="$WORKDIR/relacao-paste"
SUFFIX="relacao-suffix"

# Apenas o final page eh zerado no comeco
rm $FINAL_PAGE

# LOCK
LOCK="/volume-zabbix/lock/zbx-balancer.lck"

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

# Funcao para obter a relacao de proxies do zabbix
fn_get_proxy()
	{
cat > $JSON_PROXY <<END
{
	"jsonrpc": "2.0",
	"method": "proxy.get",
	"params": {
		"output": "extend",
		"selectInterface": "extend"
	},
	"auth": "$COOKIE",
	"id": 1
}
END


	# Gerando a lista de proxies do Zabbixt
	curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_PROXY $ZABBIX_API | grep jsonrpc > $REL_PROXY
	}

# Funcao para obter a lista de clientes do Zabbix
fn_get_client()
	{
cat > $JSON_CLIENT <<END
{
	"jsonrpc": "2.0",
	"method": "host.get",
	"params": {
		"output": ["name"]
	},
	"auth": "$COOKIE",
	"id": 1
}
END
	# Gerando a lista de clintes do Zabbix
	curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_CLIENT $ZABBIX_API | grep jsonrpc > $REL_CLIENT
	}

# Tratando os arquivos e sumarizando os clientes por proxy

fn_count_client()
	{
	PRXS=`cat $REL_PROXY | jq . | grep -w host | cut -f4 -d"\"" | grep zbxprx0 | grep -v zbxprx02`
	
	for prx in `echo $PRXS`
		do
			proxy_id=`cat $REL_PROXY | jq . | grep -w $prx -A37 | tail -n 1 | cut -f4 -d"\""`
		done

	# Gerando uma lista unica dos clientes
	cat $REL_CLIENT | jq "." | grep -w "name" | cut -f4 -d"\"" | sort -u > $REL_TOTAL

	# Iniciando o calculo

	## total de clientes
	TT_CLIENT=`wc -l $REL_TOTAL | awk '{ print $1 }'`

	## total de proxy
	TT_PRX=`echo "$PRXS" | wc -l | awk '{ print $1 }'`

	DIV=`echo "$TT_CLIENT / $TT_PRX" | bc`

	## Separando a lista por arquivos com o valor da divisao
	cd $WORKDIR
	#split --additional-suffix=-$SUFFIX -a 1 -d -l $DIV $REL_TOTAL

	for prx in `echo $PRXS`
		do
			proxy_id=`cat $REL_PROXY | jq . | grep -w $prx -A37 | tail -n 1 | cut -f4 -d"\""`

			echo ",proxy:$prx,proxy_id:$proxy_id" >> $LIST_PROXIES
		done

	count=`wc -l $LIST_PROXIES | wc -l`

	while [ $count -le $TT_CLIENT ]
		do
			cat $LIST_PROXIES >> $FILE_PASTE
			count=`echo "$count + 1" | bc`
		done

	paste $REL_TOTAL $FILE_PASTE | sed 's/\t//g' | grep -v "^," > $FINAL_PAGE
	cp $FINAL_PAGE /var/www/html/zabbix-balancer/

	# Gerando a lista dos arquivos para cada client
	for CLIENT in `cat $FINAL_PAGE  | cut -f1 -d"," | sort -u`
		do 
			PROXY=`cat $FINAL_PAGE | grep "^$CLIENT" |  cut -f2 -d"," | cut -f2 -d":"`
			echo -n "# Zabbix Balancer by chef versao 2.1

EnableRemoteCommands=1

PidFile=/var/run/zabbix/zabbix_agentd.pid

LogFile=/var/log/zabbix/zabbix_agentd.log

LogFileSize=0

Server=PROXY_NAME

ServerActive=PROXY_NAME

Hostname=CLIENT_NAME

Include=/etc/zabbix/zabbix_agentd.d/*.conf

" | sed -e "s/PROXY_NAME/$PROXY/g" -e "s/CLIENT_NAME/$CLIENT/g" > /var/www/html/zabbix-balancer/$CLIENT.conf
		done

	}

fn_clean_all()
	{
	rm $LOCK
	rm /tmp/*-zbx-balancer
	rm $WORKDIR/relacao*
	}

# Executa as funcoes na ordem
fn_check_lock
fn_get_proxy
fn_get_client
fn_count_client
fn_clean_all

