#!/bin/sh

# Script que verifica se existem tickets (incidentes) abertos na nuvem da SL
# notificando via evento o Zabbix com item informativo para que a equipe de
# infraestrutura da tabajara tenha conhecimento do evento

# Autor: Ambrosia Ambrosiano
# 04/07/2018 
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com

# Mecanica: Este script utiliza o cliente em Python para SL disponivel em:
# http://softlayer-api-python-client.readthedocs.io/en/latest/install/

# Esta instalacao foi feita com o pacote tar.gz

# A chave do usuario (ambrosia.ambrosiano) foi adicionada no arquivo .softlayer do usuario root (cuidado com o uso)

# Variaves

# Diretorio de trabalho

WORK_DIR="/var/slayer"

FILE_COMP="$WORK_DIR/file-base.comp"

HOST="softlayer"

# LOCKFILE
LOCK="/tmp/slayer.lock"

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

# Exportando o proxy
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'

### LOCK
fn_check_lock()
        {
        if [ -e $LOCK ]
                then
                        echo "Arquivo de lock $LOCK encontrado, saindo..."
                        exit 0
                else
                        echo $$ > $LOCK
                        fn_get_ticket_now
        fi
        }

fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $HOST -k ticket.open -o "$MSG"
        }

fn_gera()
	{
	slcli ticket list > $FILE_COMP
	}

fn_get_ticket_now()
	{
	TT_LT=`cat $FILE_COMP | wc -c`

	if [ $TT_LT -gt 0 ]
		then
			echo "SL" >> $FILE_COMP
			MSG=`cat $FILE_COMP`
			fn_send_zabbix
		else
			MSG=0
			fn_send_zabbix
	fi
	}


fn_gera
fn_get_ticket_now

rm $FILE_COMP
