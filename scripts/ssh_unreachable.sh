#!/bin/bash
unset http_proxy
unset https_proxy
JSON_AUTH=`mktemp --suffix=-NC`
JSON_CLIENT=`mktemp --suffix=-NC`
HOSTS=`mktemp --suffix=-NC`
RESULT=`mktemp --suffix=-NC`
ZBXSND=$(which zabbix_sender)
KEY="testconnection"

fn_send_zabbix(){
 $ZBXSND -z $ZBXPRX -s $HST -k $KEY -o "$VALUE"
}

#Getting zabbix-balancers
RES_ONLINE=`curl -s http://zabbix.tabajara.intranet/zabbix-balancer/zabbix-balancer-list-client`

#Endpoint Zabbix
ZABBIX_API="http://zabbix.tabajara.intranet/zabbix/api_jsonrpc.php"

cat > $JSON_AUTH <<END
{
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
                "user": "svc_zabbix_monit",
                "password": "xxxxxxxx"
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
escape="$(echo 'vm_|vip-|Firewall|STBTRNG|PRDSOAM|PRDSOAM|PRDWCSM|PRDCOBK|STBCOBK|STBSOAM|STBWCSM|PRDPREPG|PRDSLOC|STBPOSTR|PRDDFIN|STBCDTO|PROAML1|HORP016ASTE|STBAML1|HORPWV01ASTE.tabajara.corp|prdwf02aste.tabajara.corp|VBNAPP001.prd1.tabajara.intranet|VBNAPP002.prd1.tabajara.intranet|VBNCAP001|ALPPWF03ASTE|HORP016ASTE|HORPWV02ASTE.tabajara.corp|infrajobs01.tabajara.intranet|infrajobs02.tabajara.intranet|quepe01.tabajara.intranet|VBNCAP002|VBNMAD001.tabajaradc.intranet|VBNMAD002|VBNSQL002.prd1.tabajara.intranet|VBNSQL003.prd1.tabajara.intranet|VINADD001|VINAFS001|VINAFS002|ipmi|fwoffice')"

HOSTS="$(/usr/bin/jq '.| select(.interfaces[].ip=="127.0.0.1"|not)' "$RESULT"| jq '.host, .interfaces[].ip' | xargs -n2 | egrep -v $escape | awk '{ print $1 }'| tr '[A-Z]' '[a-z]')" 

BANNER=`mktemp --suffix=-BA`

#Getting IPS - Testing nc 
for srvname in `echo $HOSTS`;do
	echo $srvname | while read x;do echo "exit"|nc -v -w1 $x 22 > $BANNER 2> /dev/null ;done
		SSH_OPEN=`cat $BANNER | head -n1 | sed -e 's/-/ /g' | sed -e 's/\_/ /g' | awk '{ print $1 }'`
			for i in `echo $SSH_OPEN`;do 
				if [ "$i" != "SSH" ];then 
					HST=$srvname
					VALUE="SSH its unreachable"   
					ZBXPRX=`echo $RES_ONLINE | sed 's/ /\n/g' | grep "^$srvname" | awk -F',' '{ print $2 }' | cut -f2 -d":"`
					fn_send_zabbix 
					rm -f /tmp/*-BA
				else
					HST=$srvname
					VALUE="0"   
					ZBXPRX=`echo $RES_ONLINE | sed 's/ /\n/g' | grep "^$srvname" | awk -F',' '{ print $2 }' | cut -f2 -d":"`
					fn_send_zabbix 
					fi 
					rm -f /tmp/*-BA
			done
done
rm -f "$RESULT"
rm -f /tmp/*-NC
