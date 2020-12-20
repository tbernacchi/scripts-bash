#!/bin/bash
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
CNAB_TIME='/opt/silocarquivos/scripts/lists/cnab_time.list'
CNAB_LIST='/opt/silocarquivos/scripts/lists/cnab.list'

/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - prd-mon-cnab - [INFO] Evento: %e - file_dir: %f - %w%f" --event create,moved_to /jobs/prd/liquidacao/input | while read FILE
do
	filename=$(echo $FILE | awk '{print $NF}')
	echo $filename >> $CNAB_LIST
	echo "`date +"%Y-%m-%d %H:%M:%S"`;$filename" >> $CNAB_TIME
	echo "`date +"%Y-%m-%d %H:%M:%S"` - prd-mon-cnab - [INFO] [liquidacao/input] Novo arquivo $filename recebido, enviado para fila de CNABs recebidos" >> $LOG_FILE
done
