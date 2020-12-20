#!/bin/sh

# Script que invoka (executa) PS no servidor monitinfra01 para coletar o status do VMWare suas VMs
# Item: Resource das VMs

# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Data: 05/01/2019

# Variaveis:

USER="svc-virt-prod"
PASS="kwf4384R?"

REMOTE="infrajobs01.tabajara.local"

SCRIPT="c:/scripts/monitoria-integrada/exec_get-vcpu-2-cpu.bat"

RESULT_TEMP="/tmp/result-v2cpu-temp.log"
RESULT="/tmp/result-v2cpu.log"
UNIQMAXVCPU="12"
UNIQMAXCHIP="1"

TTMAXVCPU="24"
TTMAXCHIP="2"

# LOCKFILE
LOCK="/tmp/v2cpu.lck"

ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

KEY="vCPU-2-CPU"

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


fn_send_zabbix()
        {
        $ZBXSND -z $ZBXPRX -s $VM -k $KEY -o "$MSG"
        }


fn_exec_get()
	{
	###
	# Executando os procedimentos de criacao e copia dos arquivos
	sshpass -p $PASS ssh $USER@$REMOTE "$SCRIPT" > $RESULT_TEMP
	cat $RESULT_TEMP | tr -d "\r" > $RESULT

	# executa o processamento
	fn_proc_vms
	}

fn_proc_vms()
	{
	VMS=`cat $RESULT | grep -w "name" | awk '{ print $3 }'`

	for VM in `echo $VMS`
		do
			VCPU=`cat $RESULT | grep -w "$VM" -A2 | grep -w "CPUSocket" | awk '{ print $3 }'`
			CHIP=`cat $RESULT | grep -w "$VM" -A2 | grep -w "Corepersocket" | awk '{ print $3 }'`

			if [ $VCPU -gt $UNIQMAXVCPU ]
				then
					MSG="VM - Problema - vCPU eh maior que o maximo da pastilha"
					VM="vm_$VM"
					fn_send_zabbix

					if [ $CHIP -gt $TTMAXCHIP ]
						then
							MSG="Problema - Qtd - Chips maior que a pastilha"
							VM="vm_$VM"
							fn_send_zabbix
						else
							MSG="0"
							VM="vm_$VM"
							fn_send_zabbix

					fi
				elif [ $VCPU -le $UNIQMAXVCPU ]
					then
						if [ $CHIP -gt $TTMAXCHIP ]
							then
								MSG="Problema - Chips maior que a pastilha"
								VM="vm_$VM"
								fn_send_zabbix
							else
								MSG="0"
								VM="vm_$VM"
								fn_send_zabbix
						fi
			fi
		done
	}

fn_gc()
	{
	rm -f $LOCK
	rm -f $RESULT
	rm -f $RESULT_TEMP
	}

fn_check_lock
fn_gc
