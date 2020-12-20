#!/bin/bash
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
RET_TIME='/opt/silocarquivos/scripts/lists/cd_ret_time.list'
RET_LIST='/opt/silocarquivos/scripts/lists/cd_retorno.list'

/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - prd-mon-cip-entrada - [INFO] Evento: %e - file_dir: %f - %w%f" --event create,moved_to /jobs/prd/CIP/entrada/ | while read FILE
do
	filename=$(echo $FILE | awk '{print $NF}')
  echo $filename >> $RET_LIST
	echo "`date +"%Y-%m-%d %H:%M:%S"`;$filename" >> $RET_TIME
	echo "`date +"%Y-%m-%d %H:%M:%S"` - prd-mon-cip-entrada - [INFO] [CIP/entrada] Novo arquivo $filename recebido, enviando para envio a lista de transferencia para o Siloc" >> $LOG_FILE
done
