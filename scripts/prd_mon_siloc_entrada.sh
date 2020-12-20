#!/bin/bash
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
RET_TIME='/opt/silocarquivos/scripts/lists/siloc_entrada_time.list'
RET_LIST='/opt/silocarquivos/scripts/lists/siloc_retorno.list'

/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - retorno-cip - [INFO] Evento: %e - file_dir: %w%f" --event moved_to,moved_from /opt/silocarquivos/cip/entrada/ | while read FILE
do
  filename=$(echo $FILE | awk '{print $NF}')
  echo "`date +"%Y-%m-%d %H:%M:%S"`;$filename" >> $RET_STATS
	echo "`date +"%Y-%m-%d %H:%M:%S"` - prd-transfer-file - [INFO] [CIP/entrada] Novo arquivo $filename recebido, enviando para envio a lista de transferencia para o Siloc" >> $LOG_FILE
done
