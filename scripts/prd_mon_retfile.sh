#!/bin/bash
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
SENT_TIME='/opt/silocarquivos/scripts/lists/sent_time.list'
RET_TIME='/opt/silocarquivos/scripts/lists/cd_ret_time.list'
ERR_FILE='/opt/silocarquivos/scripts/lists/ret_err_file.list'
#/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - retorno-cip - [INFO] Evento: %e - file_dir: %w%f" --event create,moved_to /opt/silocarquivos/cip/entrada/ | while read file_entrada
for file_entrada in $(cat $RET_TIME)
do
  if [[ $file_entrada == *_PRO ]] || [[ $file_entrada == *_ERR ]] || [[ $file_entrada == *_RET ]]
	then
		filename=$(echo $file_entrada | awk -F';' '{print $NF}')
		fname=$(echo $filename | awk -F'/' '{print $NF}')
		ext=$(echo $fname | awk -F'_' '{print $NF}')
		echo "`date +"%Y-%m-%d %H:%M:%S"` - retorno-cip - [INFO] Retornado arquivo $filename da cip" >> $LOG_FILE
		cfile=$(echo $fname | awk -F"_$ext" '{print $1}')
		now=$(date +"%Y-%m-%d %H:%M:%S")
		saida=$(grep $cfile $SENT_TIME | awk -F";" '{print $1}')
		retorno=$(grep $cfile $RET_TIME | grep $ext | awk -F";" '{print $1}')
		if [ $file_entrada == *_ERR ]
		then
			FNAME_ERR=$file_entrada
			/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -k cipErrRetFile -o 1
			echo "`date +"%Y-%m-%d %H:%M:%S"` - cip-flow - [ERROR] Retornado arquivo $FNAME_ERR da cip com ERR" >> $LOG_FILE
		fi
	 	if [ "$saida" != '' ] || [ "$retorno" != '' ]
		then
			retorno=$(grep $cfile $RET_TIME | grep $ext | awk -F";" '{print $1}')
			delta=$(/bin/python /opt/silocarquivos/scripts/difftime.py "$saida" "$retorno")
			echo "`date +"%Y-%m-%d %H:%M:%S"` - cip-flow - [INFO] O Arquivo $filename retornou em $delta minutos após ser enviado a cip com o codigo $ext" >> $LOG_FILE
			#/bin/zabbix_sender -z zabbix.tabajara.local -s vintws001.tabajara.local -k cipRetTimeTaken -o $delta
      if [[ $file_entrada == *_PRO ]]
      then
          sudo sed -i '/'$fname'/d' $RET_TIME
      fi
			if [[ $file_entrada == *_RET ]] || [[ $file_entrada == *_ERR ]]
			then
			    sudo sed -i '/'$fname'/d' $SENT_TIME
			    sudo sed -i '/'$fname'/d' $RET_TIME
			fi

		fi
	fi
done
