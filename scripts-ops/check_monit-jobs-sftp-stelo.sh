#!/bin/sh


# Monitoria dos transfer via SFTP para o sevidor VINFTP001

# Diretorios dos sources
DIR_SRC="/monitoracao-jobs-nfs/prd/"

CODS_CLIENTE="61825 \
	      50753 \
	      46753 \
	      57746 \
	      61196"

CLIENTES_NAO_ATIVOS="2312, 2345, 2347"
	      

TODAY=`date +%Y%m%d`

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

fn_check_file()
	{
		for cod_client in `echo $CODS_CLIENTE`
			do
				FILES_FOUND=`find $DIR_SRC -name "*$cod_client*$TODAY*" -ctime -1 | rev | awk -F"/" '{ print $1 }' | rev`

				case $cod_client in
					61825)
						DIR_SFTP="Doural"
					;;

					50753)
						DIR_SFTP="CashMonitor"
					;;

					61196)
						DIR_SFTP="Docile"
					;;

					2312)
						DIR_SFTP="Equals"
					;;

					2345)
						DIR_SFTP="Equals"
					;;

					2347)
						DIR_SFTP="Equals"
					;;

					46753)
						DIR_SFTP="FREITASBASTOS"
					;;

					57746)
						DIR_SFTP="FastRunner"
					;;
				esac

				for file_found in `echo $FILES_FOUND`
					do

						ssh svc_zabbix_monit@10.150.25.223 "test -e /home/SFTP/$DIR_SFTP/$DIR_SFTP/$file_found" > /dev/null 2>&1

						RESULT=`echo $?`

						if [ $RESULT != 0 ]
							then
								MSG_CRITICAL="CRITICAL - Arquivo $file_found nao encontrado no  /home/SFTP/$DIR_SFTP no servidor VINFTP001.prd1.tabajara.local"

								$ZBXSND -z $ZBXPRX -s MONITOR_JOBS -k SFTP.$DIR_SFTP -o "$MSG_CRITICAL"
							else
								$ZBXSND -z $ZBXPRX -s MONITOR_JOBS -k SFTP.$DIR_SFTP -o "0"
						fi
					done

		done
	}

fn_check_file
