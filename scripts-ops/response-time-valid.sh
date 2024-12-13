#!/bin/sh
## Function: To get the response time for app validacao through zuul.
## Author: Tadeu Bernacchi
## E-mail: tadeu.bernacchi@tabajara.com.br | tbernacchi@gmail.com
## Date: 05/29/2019
ENDPOINT="validacao-telefone" 
VALIDACAO="validacao-aceite
validacao-aceite-pessoa
validacao-cnae
validacao-conta
validacao-ec
validacao-email
validacao-endereco
validacao-pessoa-onboard
validacao-pessoa
validacao-telefone"
ZBXPRX="zbxprxapp01.tabajara.intranet"
ZBXSND=$(which zabbix_sender)
AGR="zuul-apigateway"
KEY="RESP"

fn_send_zabbix() {
  $ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$TIME"
}

fn_exec_curl() {

RESP="`/usr/bin/curl -X POST -H "Content-Type: application/json" -d '{}' http://zuul.tabajara.intranet/validacao-telefone/telefone/validar/pre/cadastro -s -o /dev/null -w "%{time_starttransfer}\n"`"

TIME="`echo $RESP | sed 's/,//g'`"

fn_send_zabbix
}

#Main
fn_exec_curl 

