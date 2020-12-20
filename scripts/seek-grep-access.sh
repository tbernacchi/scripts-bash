#!/bin/sh

# Script para verificar o tempo de resposta (connect e outros)
# das URLs passadas pelo proxy.
# No grafana temos um select para identificar qual URL eh o alvo
# author: Ambrosia Ambrosiano

# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com

# LOGFILE
LOG_FILE=/var/log/squid/access.log

# TEMPFILE
TEMP_FILE="/tmp/squid-trash.log"

## BYTEDB
BYTEDB="/var/db/access-squid.db"
## PID
LOCK="/tmp/seek-access-squid.pid"
################################

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)
FILECONF="/etc/zabbix/zabbix_agentd.conf"

## Gerando o hostname
HST=`hostname -f | tr '[:upper:]' '[:lower:]'`

fn_send_zabbix()
        {
        $ZBXSND -c $FILECONF -k $ITEM -o "$MSG"
        }

fn_check_lock()
  {
  ## Valida/cria LOCK
  if [ -f $LOCK  ]
    then
      exit 1
    else
      /bin/touch $LOCK
      fn_seek_log
  fi
  }

fn_seek_log()
  {
  ## Valida/cria LOCK
  ## Valida se o arquivo eh novo
  ATUAL=$(ls -l $LOG_FILE | awk '{print $5}')
  ULTIMO=$(cat $BYTEDB)
  if [ $ULTIMO -gt $ATUAL ]
    then
      echo "0" > $BYTEDB
  fi

  ## Le o log iniciando no SEEKDB
  SEEK=$(cat $BYTEDB)

  MSG=`tail -c +$SEEK $LOG_FILE > $TEMP_FILE`

  ## grava o seek
  NOVOSEEK=$(echo "$ATUAL" > $BYTEDB)
 
  # funcao de calc
  fn_find_str
  }

fn_find_str()
  {
  # Lista de urls buscadas
  # Shopfacil - usados em boletos - meiosdepagamentobradesco.com.br
  # teste
  # Url braspag: https://apistress.tabajaraecommerce.tabajara.com.br
  # Url query braspag: https://apiquerystress.tabajaraecommerce.tabajara.com.br
  # Url tabajara: ecommercestress.tabajara.com.br
  URLS="meiosdepagamentobradesco.com.br \
        api.braspag.com.br \
        acs1.bradescocartoes.com.br \
        api.tabajaraecommerce.tabajara.com.br \
        apistress.tabajaraecommerce.tabajara.com.br \
        apiquerystress.tabajaraecommerce.tabajara.com.br \
        ecommercestress.tabajara.com.br"

  for url in `echo $URLS`
    do
      TT_MATCH=`grep $url $TEMP_FILE | wc -l`
      TT_TIME=`grep $url $TEMP_FILE | awk '{print $NF'} | paste -sd+ | bc`

      TT_AVG=`echo "($TT_TIME / $TT_MATCH) / 1000" | bc`

      ITEM=$url
      MSG=$TT_AVG

      fn_send_zabbix
    done
  }

fn_gc()
  {
  rm -f $LOCK
  rm -f $TEMP_FILE
  }
fn_check_lock
fn_gc
