#!/bin/sh

LOCK="/tmp/transf-ecf.lock"

WRK_DIR="/shares/dfinarquivos/saida/ecf"
WRK_DONE="/shares/dfinarquivos/saida/ecf/movidos"

FOOTER="9014625224000101"

### LOCK
fn_check_lock()
{
 if [ -e $LOCK ]
   then
     echo "Arquivo de lock $LOCK encontrado, saindo..."
     exit 0
   else
     echo $$ > $LOCK
     fn_transf_files
  fi
}

fn_transf_files()
{
for LS_FILE in `find $WRK_DIR -maxdepth 1 -type f -ctime -1 -name "*.txt"`
do
  tail -n1 $LS_FILE | grep -w $FOOTER > /dev/null
  RESULT=`echo $?`

  if [ $RESULT == 0 ]
  then
    sshpass -f /root/.ssh/key scp $LS_FILE svc_transfer_file@infrajobs02.tabajara.intranet:c:/arquivo_ecf_temp/ponte
    sshpass -f /root/.ssh/key ssh svc_transfer_file@infrajobs02.tabajara.intranet 'c:/arquivo_ecf_temp/script/exec_copy.bat'

    # move o arquivo no final
    mv $LS_FILE $WRK_DONE
  fi

done
}

fn_gc()
{
  rm -f $LOCK
}

# main
fn_check_lock
fn_gc
