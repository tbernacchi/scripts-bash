#!/bin/sh

# Script que invoka (executa) PS no servidor monitinfra01 para coletar o status do VMWare suas VMs
# permitindo a identificacao e uma rapida recuperacao em caso de falha na virtualizacao como o 
# shutdown do DC

# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Data: 04/08/2018

# Variaveis:

USER="svc-virt-prod"
PASS="kwf4384R?"

REMOTE="infrajobs01.tabajara.local"

SCRIPT="c:/scripts/monitoria-integrada/exec_get-media-pico-cluster.bat"

# LOCKFILE
LOCK="/tmp/cpu-picomediacpu.lck"


### LOCK
fn_check_lock()
        {
        if [ -e $LOCK ]
                then
                        echo "Arquivo de lock $LOCK encontrado, saindo..."
                        exit 0
                else
                        echo $$ > $LOCK
			fn_exec_get
        fi
        }



fn_exec_get()
	{
	###
	# Executando os procedimentos de criacao e copia dos arquivos
	sshpass -p $PASS ssh $USER@$REMOTE "$SCRIPT"
	}

fn_gc()
	{
	rm -f $LOCK
	}

fn_check_lock
fn_gc
