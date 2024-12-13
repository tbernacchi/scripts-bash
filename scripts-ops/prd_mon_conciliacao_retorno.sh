#!/bin/bash
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
RET_LIST='/opt/silocarquivos/scripts/lists/retorno_ret.list'

/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - mon-retorno-ret - [INFO] Evento: %e - file_dir: %w%f" --event create,moved_to /jobs/prd/CIP/entrada/retorno/ | while read FILE
do
  filename=$(echo $FILE | awk '{print $NF}')
  echo $filename >> $RET_LIST
	echo "`date +"%Y-%m-%d %H:%M:%S"` - mon-retorno-ret - [INFO] [CIP/entrada/retorno] Novo arquivo de retorno $filename recebido, enviando para envio a lista de transferencia para o a conciliacao " >> $LOG_FILE
done
