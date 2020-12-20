#!/bin/bash
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
SENT_TIME='/opt/silocarquivos/scripts/lists/sent_time.list'
SAIDA_LIST='/opt/silocarquivos/scripts/lists/siloc_saida.list'

/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - prd-mon-siloc-saida - Evento: %e - file_dir: %f - %w%f" --event create,moved_to /opt/silocarquivos/cip/saida/ | while read FILE
do
	filename=$(echo $FILE | awk '{print $NF}')
	echo $filename >> $SAIDA_LIST
	echo "`date +"%Y-%m-%d %H:%M:%S"`;$filename" >> $SENT_TIME
	echo "`date +"%Y-%m-%d %H:%M:%S"` - prd-mon-siloc-saida - [INFO] [siloc/saida] Novo arquivo $filename recebido, enviando para fila de envio para a CIP" >> $LOG_FILE
done
