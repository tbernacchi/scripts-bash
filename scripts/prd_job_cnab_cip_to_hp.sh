#!/bin/bash
DIR_PSAIDA='/opt/silocarquivos/payware/saida/'
DIR_PPROCES='/opt/silocarquivos/payware/saida/processed/'
DIR_DEST='/jobs/prd/liquidacao/ret/'
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
LOG_ERRO='/opt/silocarquivos/logs/transfer_files.err'
DIR_CONKD='/jobs/prd/CONKD0001/ret/'
DIR_LIQ_PROCS='/jobs/prd/liquidacao/process/'
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | awk -F'=' '{print $NF}')
/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k job_cnab_to_hp -o 0

qf=$(ls -l /opt/silocarquivos/payware/saida/*.ret* | wc -l)
if [[ $qf -gt 0 ]]
then
	for files in $(ls -l /opt/silocarquivos/payware/saida/*.ret | awk '{print $NF}')
	do
		end=$(tail -1 $files | grep '99999999')
		if [ $? == 0 ]
		then
			cp -a $files $DIR_CONKD 2>> $LOG_ERRO
			if [ $? == 0 ]
			then
				mv $files $DIR_LIQ_PROCS
				echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-to-hp - [INFO] Arquivo cnab $files movido para o liquidacao/process com sucesso " >>  $LOG_FILE
				/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k status_cnab_to_hp -o 0
			else
				echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-to-hp - [ERROR] Falha ao mover o arquivo $files para o diretorio liquidacao/process " >>  $LOG_FILE
				/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k status_cnab_to_hp -o 1
			fi
		else
			 echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-to-hp - [INFO] Arquivo $files esta incompleto, sera enviado na proxima execucao " >>  $LOG_FILE
		fi
	done
fi

#99999999
