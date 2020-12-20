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

SCRIPT="c:/scripts/rotinas/reports/exec_get-vm-pws.bat"

REMOTE_DIR="c:/scripts/reports/*"

LOCAL_DIR="/var/www/html/reports/"

###
# Executando os procedimentos de criacao e copia dos arquivos
sshpass -p $PASS ssh $USER@$REMOTE "$SCRIPT"

sshpass -p $PASS scp $USER@$REMOTE:$REMOTE_DIR $LOCAL_DIR

DT=`date +%d-%m-%Y`

zip -r /tmp/report-$DT.zip $LOCAL_DIR/*$DT*

mpack -s "Relatorio VMWare - $DT" /tmp/report-$DT.zip gr_infra@tabajara.com.br

rm -f /tmp/report-$DT.zip


