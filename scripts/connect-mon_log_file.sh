#!/bin/bash
/usr/bin/inotifywait --timefmt "%Y-%m-%d %H:%M:%S" --quiet --monitor --format "%T - connect-mon-log-file - [INFO] Evento: %e - file_dir: %f - %w%f" --event create /connect/cdunix/work/vintws001ibm/ | while read FILE
do
	filename=$(echo $FILE | awk -F'/' '{print $NF}')
	first=$(echo $filename | cut -c1-4)
	if [ $first == S201 ]; then
		echo "`date +"%Y-%m-%d %H:%M:%S"` - connect-new-log-file - [INFO] Novo arquivo $filename de log gerado pelo Connect Direct." >> /var/log/connect-cip-job.log
		curl -X GET -H "X-Rundeck-Auth-Token: wuDJmllLZiheVFe4lX6JdusY2smq3CXA" http://rundeck.tabajara.intranet/api/1/job/cc2e1cc1-3069-4d29-a09c-8462098351f0/run
	fi
done
