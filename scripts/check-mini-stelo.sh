#!/bin/sh

# Script:  check-mini-tabajara.sh
# Function: Script is used for monitoring access and auth for moni-tabajara
# This script have two phases:
# First: Get de token : pool-fogueira
# Second: Use de token in pool-quinhao

USER="monitoreum1@tabajara.com.br"
PASS="St3l@2015"

HOSTS_AUTH="fogueira01.tabajara.intranet \
            fogueira02.tabajara.intranet"

URI_AUTH="api/oauth/token"

HOSTS_MINI="quinhao01.tabajara.intranet \
	          quinhao02.tabajara.intranet"

URI_MINI="mini-api/clientinfo"

SCRIPT="/tmp/execs.sh"

ZBXPRX="zbxprxapp01.tabajara.intranet"
ZBXSND=$(which zabbix_sender)
AGR="mini-tabajara"
KEY="AUTH"
FILE="/tmp/status-mini"

fn_send_zabbix()
        {
          $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$MSG"

        }

fn_exec_get()
  {
  for host_auth in `echo $HOSTS_AUTH`
    do
      TOKEN=`curl -s -X POST  --header 'Host: mini.tabajara.com.br' http://$host_auth/$URI_AUTH  -H 'Authorization: Basic YXBwLW1pbmk6MTIzNDU2'  -H 'Content-Type: application/x-www-form-urlencoded'  -H 'Postman-Token: 5b743499-8cab-408c-8ad5-ef2c8d4ea385'  -H 'cache-control: no-cache'  -d 'grant_type=password&password=St3l@2015&scope=read&username=monitoreum1@tabajara.com.br&undefined=' | jq .access_token | sed 's/"//g'`

      for host_mini in `echo $HOSTS_MINI`
        do
          echo "curl -s -X GET  --header 'Host: mini.tabajara.com.br' http://$host_mini/$URI_MINI -H 'Access-Control-Allow-Headers: x-requested-with, authorization, cache-control'  -H 'Authorization: bearer $TOKEN'  -H 'Content-Type: application/json'  -H 'Postman-Token: 3756c34f-4622-4e01-b02a-21e7c36d50e4'  -H 'cache-control: no-cache' | jq .code" > $SCRIPT
       
          sh -x $SCRIPT | grep 200
          RESULT=`echo $?`

          if [ $RESULT == 0 ]
            then
                echo "Auth OK" >> $FILE
            else
                echo "Falha - $host_mini" >> $FILE
          fi
        done
    done
  }

fn_check_status()
  {
  cat $FILE | grep Falha
  RESULT=`echo $?`

  if [ $RESULT != 0 ]
     then
       MSG="0"
       fn_send_zabbix
     else
       MSG=`cat $FILE | sort -u | sed ':a;$!N;s/\n/ /g;ta'`
       fn_send_zabbix
  fi
  }

fn_gc()
  {
  rm -f $FILE $SCRIPT
  }

fn_exec_get
fn_check_status
fn_gc
