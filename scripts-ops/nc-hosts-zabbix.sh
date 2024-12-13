#!/bin/bash
# Script para verificar se o host esta inacessível (SSH its unreachable).
# Autor: Tadeu Bernacchi
# Email: tadeu.bernacchi@tabajara.com.br | tbernacchi@gmail.com

unset http_proxy
unset https_proxy
JSON_AUTH=`mktemp --suffix=-NC`
JSON_CLIENT=`mktemp --suffix=-NC`
HOSTS=`mktemp --suffix=-NC`
RESULT=`mktemp --suffix=-NC`
ZBXSND=$(which zabbix_sender)
KEY="testconnection"

LOCK="/tmp/nc-lock"

# LOCK
### LOCK
fn_check_lock()
        {
        if [ -e $LOCK ]
          then
            rm -f `find $LOCK -cmin +10`
            echo "Arquivo de lock $LOCK encontrado, saindo..."
            exit 0
          else
            echo $$ > $LOCK
            fn_exec_nc
        fi
        }
                                                                                                                                                                                              

fn_send_zabbix(){
 $ZBXSND -z $ZBXPRX -s $HST -k $KEY -o "$VALUE"
}

fn_exec_nc()
  {
  #Getting zabbix-balancers
  RES_ONLINE=`curl -s http://zabbix.tabajara.local/zabbix-balancer/zabbix-balancer-list-client`

  #Endpoint Zabbix
  ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

cat > $JSON_AUTH <<END
{
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
                "user": "svc_zabbix_monit",
                "password": "kwf4384R?"
        },
        "id": 1,
        "auth": null
}

END

  # Getting cookie 
  COOKIE=`curl -s -i -X POST -H 'Content-Type:application/json' -d@$JSON_AUTH $ZABBIX_API | tail -n1 | jq '.result' | sed 's/\"//g'`

cat > $JSON_CLIENT <<END
 {
     "jsonrpc": "2.0",
     "method": "host.get",
     "params": {
         "output": [
             "hostid",
             "host"
         ],
         "selectInterfaces": [
             "interfaceid",
             "ip",
             "host"
         ]
     },
     "id": 2,
     "auth": "$COOKIE"
}
END

  #Getting HOSTS - Curl
  curl -s -i -H 'Content-Type: application/json-rpc' -d@$JSON_CLIENT $ZABBIX_API | awk '{if (NR> 11) print}' | jq -r '.result[]' > "$RESULT" 

  #Getting HOSTS
  escape="$(echo 'vm_|vip-|Cisco|10.140.83.254|10.150.238.241|10.150.238.235|Firewall|STBTRNG|PRDSOAM|PRDSOAM|PRDWCSM|PRDCOBK|STBCOBK|STBSOAM|STBWCSM|PRDPREPG|PRDSLOC|STBPOSTR|PRDDFIN|STBCDTO|PROAML1|HORP016ASTE|STBAML1|HORPWV01ASTE.tabajara.corp|prdwf02aste.tabajara.corp|VBNAPP001.prd1.tabajara.local|VBNAPP002.prd1.tabajara.local|VBNCAP001|ALPPWF03ASTE|HORP016ASTE|HORPWV02ASTE.tabajara.corp|infrajobs01.tabajara.local|infrajobs02.tabajara.intranet|quepe01.tabajara.intranet|VBNCAP002|VBNMAD001.tabajaradc.local|VBNMAD002|VBNSQL002.prd1.tabajara.local|VBNSQL003.prd1.tabajara.local|VINADD001|VINAFS001|VINAFS002|ipmi|fwoffice')"

  HOSTS="$(/usr/bin/jq '.| select(.interfaces[].ip=="127.0.0.1"|not)' "$RESULT"| jq '.host, .interfaces[].ip' | xargs -n2 | egrep -v $escape | awk '{ print $1 }'| tr '[A-Z]' '[a-z]')" 

  BANNER=`mktemp --suffix=-BA`
  #Getting IPS - Testing nc 
  for srvname in `echo $HOSTS`
    do
      sleep 1

      echo $srvname
      BANNER=`echo "exit" | nc -v -w 3 $srvname 22`

      echo $BANNER |  head -n1 | sed -e 's/-/ /g' | sed -e 's/\_/ /g' | awk '{ print $1 }' | grep -w "SSH" > /dev/null

      RESULT=`echo $?`
      echo $RESULT

      if [ $RESULT -eq 0 ]
        then
          HST=$srvname
          VALUE="0"
          ZBXPRX=`echo $RES_ONLINE | sed 's/ /\n/g' | grep "^$srvname" | awk -F',' '{ print $2 }' | cut -f2 -d":"`
          fn_send_zabbix
        else
          HST=$srvname
          VALUE="SSH its unreachable"
          ZBXPRX=`echo $RES_ONLINE | sed 's/ /\n/g' | grep "^$srvname" | awk -F',' '{ print $2 }' | cut -f2 -d":"`
          fn_send_zabbix
      fi
      
    done

    rm -f "$RESULT"
    rm -f /tmp/*-NC
    rm -f /tmp/*-BA
    rm -f $LOCK
  }

fn_check_lock
