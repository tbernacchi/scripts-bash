#!/bin/bash
# Script para copiar arquivos EDI entre Linux/Windows sem pagamento de licença.
# Autor: Ambrosia Ambrosiano
# Email: ambrosia.ambrosiano@tabajara.com.br
# Date: 04/18/2019

# VARS
DIR_ORIG=/jobs/relatorio-base-elo
DIR_ORIG_MOVE=/jobs/relatorio-base-elo/moved
FILE_TIME=60

cd $DIR_ORIG

# Variaveis
## Agente de envio
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf|awk -F'=' '{print $2}')
ZBXSND=$(which zabbix_sender)
ZBXTRAPPER="ZGOSSIP01-STREET-TRANSFERFILE"
SENHA='s2H&ltal'

# hostname
HST=$(hostname -f |tr 'A-Z' 'a-z')

# LOCKFILE
LOCK="/tmp/transf-street-report.lock"

### FUNCTIONS

fn_check_lock()
{
	if [ -e $LOCK ]
	then
		if [ -e $(find /tmp/ -maxdepth 1 -wholename $LOCK -cmin +${FILE_TIME}) ]
		then
			#$LOCK with more of $FILE_TIME. Deleting the file"
			rm -f $LOCK
			fn_cria_lock
		else
			#$LOCK found, exiting
			exit 0
		fi
	else
			fn_cria_lock
	fi
}

fn_send_zabbix()
{
	$ZBXSND -z $ZBXPRX -s $HST -k $ZBXTRAPPER -o "$MSG"
}

fn_cria_lock()
{
	echo $$ > $LOCK
}

fn_check_files()
{
	DATES="$(date --date '1 day ago' +%Y%m%d) $(date +%Y%m%d)"
	for i in $DATES
	do 
		TT_FL=$(find $DIR_ORIG -maxdepth 1 -type f -iname \*BASE_\*_FACILITADOR_7110_\*${i}\*.* -exec basename {} \; )
		if [ -z "$TT_FL" ]
		then
			fn_remove_lock
		else
			for i in $TT_FL
			do
				fn_md5sum_file $i
			done
		fi
	done
}

fn_remove_lock()
{
        rm -f $LOCK
}

fn_md5sum_file()
{
    while true
    do
        file=$1
        md5file=$(md5sum $DIR_ORIG/$file)
        sleep 3
        if [ "$md5file" == "$(md5sum $DIR_ORIG/$file)" ]
        then
            fn_move_file $file
            break
        fi
    done
}

fn_move_file()
{
	file1=$1
	sshpass -p "$SENHA" scp $file1 svc_transfer_file@infrajobs02.tabajara.intranet:c:/relatorios_street
	if [ "$?" -ne "0" ]
	then
		MSG="ERRO ao copiar o arquivo $file1 para o diretorio final"
		fn_send_zabbix
	else
		TT_DEST=$(sshpass -p "$SENHA" ssh svc_transfer_file@infrajobs02.tabajara.intranet 'c:/relatorios_street/script/exec_copy.bat' | tail -n1 | awk '{ print $1 }')
		if [ $TT_DEST -lt 1 ]
		then
			MSG="Falha - para copiar o arquivo para o diretorio final"
			fn_send_zabbix
			exit 1
		fi		
		mv $DIR_ORIG/$file1 $DIR_ORIG_MOVE/
		MSG="0"
		fn_send_zabbix
	fi
}

### EXECUTION
fn_check_lock
fn_check_files
fn_remove_lock
