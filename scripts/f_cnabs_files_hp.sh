CNAB_DIR='/jobs/prd/liquidacao/input/'
CNAB_DIR_PROCS='/jobs/prd/liquidacao/process/'
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
LOG_ERR='/opt/silocarquivos/logs/transfer_files.err'
LIST='/opt/silocarquivos/scripts/lists/cnab.list'
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | awk -F'=' '{print $NF}')
/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k job_cnabs_status_files -o 1

CMD=$(ls -l $CNAB_DIR | grep *SUBQ* | wc -l)

if [ $CMD == 0 ]
then
	/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k cnabs_status_files -o 0
	echo "`date +"%Y-%m-%d %H:%M:%S"` - cnabs-status-files - [ERROR] Os Arquivos Cnabs ainda nao chegaram da HP, total de arquivos: $CMD " >>  $LOG_FILE
	sleep 60

elif [ $CMD > 1 ] && [ $CMD < 13 ]
then
	/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k cnabs_status_files -o 1
	echo "`date +"%Y-%m-%d %H:%M:%S"` - cnabs-status-files - [WARN] Os Arquivos Cnabs ainda nao chegaram totalmente, total de arquivos: $CMD " >>  $LOG_FILE

else
	/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k cnabs_status_files -o 2
	echo "`date +"%Y-%m-%d %H:%M:%S"` - cnabs-status-files - [INFO] Todos os arquivos Cnabs chegaram da HP, total de arquivos: $CMD " >>  $LOG_FILE
fi
