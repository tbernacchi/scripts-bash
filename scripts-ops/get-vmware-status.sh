#!/bin/sh

### teste

# Script que invoka (executa) PS no servidor monitinfra01 para coletar o status do VMWare suas VMs
# Item: Resource das VMs

# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Data: 05/01/2019

# Variaveis:

USER="svc-virt-prod"
PASS="kwf4384R?"

REMOTE="infrajobs01.tabajara.local"

SCRIPT="c:/scripts/monitoria-integrada/exec_get-vmware-status.bat"

# LOCKFILE
LOCK="/tmp/vmware-statuss.lck"


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
