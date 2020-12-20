#!/bin/sh
# Script para transferir arquivos *.csv para a Rede Windows - TRIBUTARIO (Arquivos Base Alelo)
# Autor: Tadeu Bernacchi
# Email: tadeu.bernacchi@tabajara.com.br | tbernacchi@gmail.com
# Date: 07/23/2019

# LOCKFILE
LOCK="/tmp/transf-alelo.lock"

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

# Lista dos arquivos e suas transfers
fn_transf_files()
	{
	for LS_FILE in `find /jobs-financeiro/jp19_0004/VOUCHER_FILES -maxdepth 1 -type f -ctime -1 -name "voucher_*.csv"`
		do


					sshpass -p "s2H&ltal" scp $LS_FILE svc_transfer_file@infrajobs02.tabajara.intranet:c:/arquivo_base_alelo/entrada


					sshpass -p 's2H&ltal' ssh svc_transfer_file@infrajobs02.tabajara.intranet 'c:/arquivo_base_alelo/script/exec_copy_input.bat' 

					# Movendo os arquivos para process
					mv $LS_FILE /jobs-financeiro/jp19_0004/VOUCHER_FILES/process
		done
	}

fn_gc()
	{
	rm -f $LOCK
	}

# main
fn_check_lock
fn_gc
