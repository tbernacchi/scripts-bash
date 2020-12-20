#!/bin/sh
# Script to backup git-infra.
# Autor: Ambrosia Ambrosiano
# Adjust: Tadeu Bernacchi
# Email: ambrosia.ambrosiano@tabajara.com.br | tadeu.bernacchi@tabajara.com.br
# Date: 09/29/2019

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)
CONFFILE="/etc/zabbix/zabbix_agentd.conf"

# LOCKFILE
LOCK="/tmp/gitbackup.lck"

### LOCK
fn_check_lock()
        {
        if [ -e $LOCK ]
                then
                        echo "Arquivo de lock $LOCK encontrado, saindo..."
                        exit 0
                else
                        echo $$ > $LOCK
        fi
        }

fn_send_zabbix_critical()
        {
       	MSG_CRITICAL="CRITICAL - Backup do Git de Infra pode estar com problemas, verifique a geracao do arquivo em /var/opt/gitlab/backups"

       	$ZBXSND -c $CONFFILE -k git.backup-infra.repo -o "$MSG_CRITICAL"
        }

fn_send_zabbix_ok()
        {
       	$ZBXSND -c $CONFFILE -k git.backup-infra.repo -o 0
        }

fn_clean_local_remoto()
	{
	 find /var/opt/gitlab/backups -type f -mtime +3 -exec rm '{}' ';'
	 find /backup-git -type f -mtime +3 -exec rm '{}' ';'
	}

fn_backup_git()
	{
	gitlab-rake gitlab:backup:create > /dev/null 2>&1

	if [ `echo $?` != 0 ]
		then
			fn_send_zabbix_critical
		else
			fn_send_zabbix_ok
	fi 
	}

fn_files()
	{
	VERSION="12.3.1"
	/usr/bin/tar czf - /etc/gitlab > /var/opt/gitlab/backups/`date +%Y_%m_%d`_"$VERSION"_gitlab_files.tar.gz 2> /dev/null
	}

fn_bkp_git()
        {
        /usr/bin/tar czf - /var/opt/gitlab/backups > /tmp/`date +%Y_%m_%d`_"$VERSION"_gitlab.tar.gz 2> /dev/null
        }

fn_full()
        {
	/usr/bin/tar czf  - /var/opt/gitlab/backups/`date +%Y_%m_%d`_"$VERSION"_gitlab_files.tar.gz /var/opt/gitlab/backups/`date +%Y_%m_%d`_"$VERSION"_gitlab.tar.gz > /backup-git/`date +%Y_%m_%d`_"$VERSION"_gitlab_full.tar.gz 2> /dev/null
        }

fn_gc()
	{
	rm $LOCK
	}

fn_check_lock
fn_backup_git
fn_files
fn_bkp_git
fn_full
fn_clean_local_remoto
fn_gc
