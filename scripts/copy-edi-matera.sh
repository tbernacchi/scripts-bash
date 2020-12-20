#!/bin/sh

# Copia o arquivo do EDI do Matera de Hortolandia para a SL
# Esse arquivo eh gerado pela FINNET e precisa ser migrado para SL
# Author: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com

# Variaveis

USER="Financeiro"
PASS="ftp@1233"

REMOTE="172.20.0.46"

DIR_LOCAL="/var/matera/edi"

ANOFULL=`date +%Y`
ANOSHORT=`date +%y`
DIA=`date +%d`
MES=`date +%m`
MESNUM=`date +%m`
TEMPFILE=`mktemp --suffix=-matera`

# FILE
FILE="EDI4693847_1813897$DIA$MESNUM$ANOSHORT"

case $MES in
    01)
      MES="Janeiro"
      ;;

    02)
      MES="Fevereiro"
      ;;

    03)
      MES="Marco"
      ;;

    04)
      MES="Abril"
      ;;

    05)
      MES="Maio"
      ;;

    06)
      MES="Junho"
      ;;

    07)
      MES="Julho"
      ;;

    08)
      MES="Agosto"
      ;;

    09)
      MES="Setembro"
      ;;

    10)
      MES="Outubro"
      ;;

    11)
      MES="Novembro"
      ;;

    12)
      MES="Dezembro"
      ;;
esac

fn_send_zabbix()
  {
   /usr/bin/zabbix_sender -z zbxprxapp01.tabajara.intranet -s matera -k FINNET_MATERA -o "$MSG"
  }

fn_list_file_remote()
  {
ftp -n $REMOTE << EOF
  quote USER $USER
  quote PASS $PASS
  binary
  dir $ANOFULL/$MES/ 
EOF

  fn_copy_to_local
  }

fn_copy_to_local()
  {
  SEG=`date +%u`

  if [ $SEG == 1 ]
    then
      echo "eh segunda, verificamos o arquivo anterior"
      DOM=`date +%d --date="2 days ago"`
      FILE="EDI4693847_1813897$DOM$MESNUM$ANOSHORT"


      TARGET=`grep $FILE $TEMPFILE | awk '{ print $4 }'`

      cd $DIR_LOCAL

ftp -n $REMOTE << EOF
  quote USER $USER
  quote PASS $PASS
  binary
  cd $ANOFULL
  cd $MES
  get $TARGET
EOF

    sshpass -p "s2H&ltal" scp $TARGET svc_transfer_file@infrajobs02.tabajara.intranet:c:/arquivo_matera/entrada
    sshpass -p 's2H&ltal' ssh svc_transfer_file@infrajobs02.tabajara.intranet 'c:/arquivo_matera/script/exec_copy_input.bat' 

    # List
    sshpass -p 's2H&ltal' ssh svc_transfer_file@infrajobs02.tabajara.intranet 'c:/arquivo_matera/script/list-fl-saida.bat' | grep $TARGET> /dev/null
    RESULT=`echo $?`

    if [ $RESULT != 0 ]
      then
        MSG="Possivel problema com EDI do FINNET do Matera"
        fn_send_zabbix
      else
        MSG="0"
        fn_send_zabbix
    fi
  fi
  
  }

fn_gc()
  {
  rm  -f /tmp/*-matera
  rm -f `find $DIR_LOCAL -type f -ctime +7`
  }

# main
fn_list_file_remote > $TEMPFILE
fn_gc

