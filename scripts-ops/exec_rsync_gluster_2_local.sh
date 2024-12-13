#!/bin/sh

# Script para executar o rsync do gluster (remoto) para o diretorio local
# Desse modo a indisponibilidade do gluster nao causa impacto na publicacao
# de marketing.

# Rotina usando o rsync

DIR_REMOTO="/SFTP-produtos/marketing-admin/marketing-admin"
DIR_LOCAL="/var/www/html/"

RSYNC=$(which rsync)
PARAMS="-az"

ZBXSND=$(which zabbix_sender)

CONFFILE="/etc/zabbix/zabbix_agentd.conf"
ITEM="RSYNC-MARKETING"

fn_send_zabbix()
	{
	$ZBXSND -c $CONFFILE -k $ITEM -o "$MSG"
	}

fn_exec_rsync()
	{
	NEW_FILES=`find $DIR_REMOTO -mtime -1 | wc -l`

	if [ $NEW_FILES -gt 0 ]
		then
			$RSYNC -az $DIR_REMOTO/* $DIR_LOCAL
			result=`echo $?`

			if [ $result != 0 ]
				then
					MSG="Erro ao executar o rsync do diretorio de marketing"
					fn_send_zabbix
				else
					MSG="0"
					fn_send_zabbix
			fi
		else
			MSG="0"
			fn_send_zabbix
	fi
	}

fn_exec_rsync
