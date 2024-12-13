#!/bin/sh

SERVERS="VBNAPP003.prd1.tabajara.local VBNAPP004.prd1.tabajara.local"

STRING="Senha"

# LOCKFILE
LOCK="/tmp/test-portal.lck"

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

### LOCK
fn_check_lock()
	{
	if [ -e $LOCK ]
		then
			echo "Arquivo de lock $LOCK encontrado, saindo..."
			exit 0
		else
			echo $$ > $LOCK
			fn_exec_test
	fi
	}

fn_send_zabbix_ok()
	{
	MSG_OK="Login Portal Office Form Server: $SRV $server OK"

	$ZBXSND -z $ZBXPRX -s $server -k Form.Office.Portal -o "$MSG_OK"
	}

fn_send_zabbix_critical()
	{
	MSG_CRITICAL="Login Portal Office Form Server: $SRV $server CRITICAL"

	$ZBXSND -z $ZBXPRX -s $server -k Form.Office.Portal -o "$MSG_CRITICAL"

	}
fn_exec_test()
	{
	# Fazendo o post e salvando o cookie

	for server in `echo $SERVERS`
		do
			EP_LOGIN="http://$server:7111/portal/login"
			DATA=`curl -s $EP_LOGIN`

			echo $DATA | grep -w $STRING > /dev/null

			if [ `echo $?` == 0 ]
				then
					fn_send_zabbix_ok
				else
					fn_send_zabbix_critical
			fi
		done
	}

fn_clean()
	{
	rm $LOCK
	}

# main
fn_check_lock
fn_clean

