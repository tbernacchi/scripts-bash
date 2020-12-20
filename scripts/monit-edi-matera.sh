#!/bin/sh

# Script para monitorar se o arquivo de EDI do Finnet usado no Matera
# Foi salvo no share final no servidor windows para upload dentro do
# Matera
# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# 16/05/2019

ANOFULL=`date +%Y`
ANOSHORT=`date +%y`
DIA=`date +%d`
MES=`date +%m`

# FILE
FILE="EDI4693847_1813897$DIA$MES$ANOSHORT"

fn_send_zabbix()
  {
   /usr/bin/zabbix_sender -z zbxprxapp01.tabajara.intranet -s matera -k FINNET_MATERA -o "$MSG"
  }

fn_check_weekend()
  {
    DAY=`date +%A`

    case $DAY in
      Sunday)
        MSG="0"
        ;;

      Monday)
        MSG="0"
        ;;

      *)
        fn_check_file
        ;;
    esac

    fn_send_zabbix
  }

fn_check_file()
  {
  DT_FILE=`sshpass -p 's2H&ltal' ssh svc_transfer_file@infrajobs02.tabajara.intranet c:/arquivo_matera/script/list-fl-saida.bat | grep EDI | tail -n1 | awk '{ print $1 }'`
  NM_FILE=`sshpass -p 's2H&ltal' ssh svc_transfer_file@infrajobs02.tabajara.intranet c:/arquivo_matera/script/list-fl-saida.bat | grep EDI | tail -n1 | awk '{ print $5 }'`

  TODAY=`date +%m/%d/%Y`

  if [ $DT_FILE != $TODAY ]
    then
      MSG="Possivel problema com EDI do FINNET do Matera - Data do arquiv $NM_FILE  $DT_FILE"
      fn_send_zabbix
    else
      MSG="0"
      fn_send_zabbix
  fi
  }

# main
fn_check_weekend
