#!/bin/sh

# Script para obter e atualizar o zabbix-agent via zabbix-balancer
# Obter o proxy name e o proxy_id que esta sendo entregue pelo 
# zabbix., atualizar o client, atualizar o BD (via API) e reiniciar o client.
# Ao final o script eh removido

#CMDS

SYSTEMCTL=$(which systemctl)

# Variaveis
# Exportando o proxy
#export https_proxy=http://proxy.tabajara.intranet:3130/
#export http_proxy=http://proxy.tabajara.intranet:3130/
#export no_proxy='.tabajara.local, .tabajara.intranet, 10.0.0.0/8'
unset http_proxy
unset https_proxy

# Arquivo de configuracao
FILECONF="/etc/zabbix/zabbix_agentd.conf"

# Nome do cliente - usamos o short name para facilitar o grep
HOST=`cat $FILECONF | grep Hostname | cut -f2 -d"="`

# Gera o resultado online
RES_ONLINE=`curl -s http://zabbix.tabajara.local/zabbix-balancer/zabbix-balancer-list-client | grep $HOST`

# URL para receber o POST com o update do proxy, pois o host.update nao contem o update deste item via API
# Foi criado um WS simples para executar esse update via BD
WS_UPDATE="http://zabbix.tabajara.local/zabbix-balancer/ws/update-zabbix-proxy.php"

# Arquivo de configuracao

# Gera o resultado online

PRX_LOCAL=`cat $FILECONF  | egrep "Server|ServeActive" | cut -f2 -d"=" | sort -u | head -n1`

PRX_ONLINE=`echo $RES_ONLINE | grep $HOST | awk -F',' '{ print $2 }' | cut -f2 -d":"`

PRX_ID_ONLINE=`echo $RES_ONLINE | grep $HOST | cut -f3 -d":"`

HOST_ONLINE=`echo $RES_ONLINE | grep $HOST | awk -F',' '{ print $1 }'`

if [ $PRX_LOCAL != $PRX_ONLINE ]
	then
		sed -i "s/$PRX_LOCAL/$PRX_ONLINE/g" $FILECONF

		# Reinicia o servico
		$SYSTEMCTL restart zabbix-agent
		/etc/init.d/zabbix-agent restart

		# Executando o update
		curl --data "proxy_hostid=$PRX_ID_ONLINE&host=$HOST_ONLINE" -X POST $WS_UPDATE

	else

		echo "nao altera nada"

fi

###

#remove tudo inclusive o script
#rm -f $0

