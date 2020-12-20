#!/bin/sh

# Script para obter e atualizar o zabbix-agent via zabbix-balancer
# Obter o proxy name e o proxy_id que esta sendo entregue pelo
# zabbix., atualizar o client, atualizar o BD (via API) e reiniciar o client.
# Ao final o script eh removido

#CMDS

# Variaveis
# Exportando o proxy
#export https_proxy=http://proxy.tabajara.intranet:3130/
#export http_proxy=http://proxy.tabajara.intranet:3130/
#export no_proxy='.tabajara.local, .tabajara.intranet, 10.0.0.0/8'
unset http_proxy
unset https_proxy

# Arquivo de configuracao
FILECONF="/etc/zabbix/zabbix_agentd.conf"

# LOG
ZBXLOG="/var/log/zabbix/zabbix_agentd.log"

# Nome do cliente - usamos o short name para facilitar o grep
HOST=`hostname -s | cut -f1 -d"."`

# Gera o resultado online
RES_ONLINE=`curl -s http://zabbix.tabajara.local/zabbix-balancer/zabbix-balancer-list-client | grep -i "^$HOST"`

# URL para receber o POST com o update do proxy, pois o host.update nao contem o update deste item via API
# Foi criado um WS simples para executar esse update via BD
WS_UPDATE="http://zabbix.tabajara.local/zabbix-balancer/ws/update-zabbix-proxy.php"

# Separa da lista somente o hostname
HOST_ONLINE=`echo $RES_ONLINE | grep -i "^$HOST" | awk -F',' '{ print $1 }'`

PRX_ONLINE=`echo $RES_ONLINE | grep -i "^$HOST" | awk -F',' '{ print $2 }' | cut -f2 -d":"`

PRX_ID_ONLINE=`echo $RES_ONLINE | grep -i "^$HOST" |  cut -f3 -d":"`

PRX_LOCAL=`cat $FILECONF  | egrep "Server|ServeActive" | cut -f2 -d"=" | sort -u | head -n1`

# Verifica o md5 remoto
MD5_ONLINE=`curl http://zabbix.tabajara.local/zabbix-balancer/$HOST_ONLINE | md5sum | awk '{ print $1 }'`

# Verifica o md5 local
MD5_LOCAL=`md5sum $FILECONF | awk '{ print $1 }'`

fn_test_file()
  {
  if [ $MD5_ONLINE != $MD5_LOCAL ] ||  [ $PRX_LOCAL != $PRX_ONLINE ]
    then
        fn_get_conf
  fi
  }

fn_test_conn()
  {
   tail -n 1 $ZBXLOG | grep failed > /dev/null
   RES=`echo $?`

   if [ $RES == 0 ]
     then
         echo 0 > $FILECONF
         fn_get_conf
   fi   
  }

fn_get_conf()
  {
  # Baixamos o arquivo do zabbix server
  curl -s -o $FILECONF http://zabbix.tabajara.local/zabbix-balancer/$HOST_ONLINE

  # Executando o update
  curl --data "proxy_hostid=$PRX_ID_ONLINE&host=$HOST_ONLINE" -X POST $WS_UPDATE

  # Reinicia o servico
  systemctl restart zabbix-agent
  #/etc/init.d/zabbix-agent restart
  }
###

# main
fn_test_file
fn_test_conn

#remove tudo inclusive o script
#rm -f $0

