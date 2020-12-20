#!/bin/bash

##### Parametros de input 
###

## Regras
##

## Jobs HSTRD devem ser executados e gerarem arquivos ate as 07hs

## Jobs EXTRD devem ser executados e gerarem arquivos ate as 08hs

## Jobs GEPDD devem ser executados e gerarem arquivos em horarios variadas

# Nome JOB
JOBS_NAME="HSTRD0001 \
	   HSTRD0002 \
	   EXTRD0001 \
	   EXTRD0002 \
	   EXTRD0003 \
	   EXTRD0004 \
	   GEPDD0001 \
	   GEPDD0002 \
	   GEPDD0003 \
	   GEPDD0004 \
	   GEPDD0005"

## Agente de envio
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)

fn_send_zabbix_critical()
	{
	 MSG_CRITICAL="CRITICAL - Arquivo $FILE_STR nao gerado na data de hoje"

	 $ZBXSND -z $ZBXPRX -s MONITOR_JOBS -k $job_name -o "$MSG_CRITICAL"
	}

fn_send_zabbix_ok()
	{
	 $ZBXSND -z $ZBXPRX -s MONITOR_JOBS -k $job_name -o 0 
	}

fn_check_file()
	{
	 TODAY=`date +%Y-%m-%d`

	 FILE_WAIT=`ls -lart $DIR_CHECK/$DIR_FINAL | grep $FILE_STR | tail -n1 | awk '{ print $9 }'`
	 DAYTIME_CREATE=`stat -c %y $DIR_CHECK/$DIR_FINAL/$FILE_WAIT`
	
	 DAY=`echo $DAYTIME_CREATE | awk '{ print $1 }'`
	 TIME=`echo $DAYTIME_CREATE | awk ' { print $2 }' | cut -f1 -d":"`

	 if [ $DAY != $TODAY ]
		then
			fn_send_zabbix_critical
		else
			fn_send_zabbix_ok
	 fi
	}

for job_name in `echo $JOBS_NAME`
	do
		case $job_name in
			$job_name)

				DIR_CHECK="/monitoracao-jobs-nfs/prd/$job_name"

				if [ $job_name == HSTRD0001 ] || [ $job_name == HSTRD0002 ]
					then
						HORA="07"
						DIR_FINAL="proces"

						if [ $job_name == HSTRD0001 ]
							then
								FILE_STR="SUBQ_TRANSDIA_HSTR"

								fn_check_file

							elif [ $job_name == HSTRD0002 ]
								then
									FILE_STR="SUBQ_PRCLIQTR_HSTR"
						fi

					elif [ $job_name == EXTRD0001 ] || [ $job_name == EXTRD0002 ] || [ $job_name == EXTRD0003 ]
						then
							HORA="08"
							DIR_FINAL="ret/proces"

							if [ $job_name == EXTRD0001 ]
								then
									FILE_STR="EXTR_"

									fn_check_file

								elif [ $job_name == EXTRD0002 ]
									then
										FILE_STR="EXTR_"

								elif [ $job_name = EXTRD0003 ]
									then
										FILE_STR="EXTR_"
							fi

					elif [ $job_name == GEPDD0001 ] || [ $job_name == GEPDD0002 ]
						then
							HORA="03"
							DIR_FINAL="ret/proces"

							if [ $job_name ==  ]
								then
									FILE_STR="EXTR_"

									fn_check_file

								elif [ $job_name == EXTRD0002 ]
									then
										FILE_STR="EXTR_"
							fi

					elif [ $job_name == GEPDD0003 ]
						then
							HORA="14"

					elif [ $job_name == GEPDD0004 ]
						then
							HORA="22"

					elif [ $job_name == GEPDD0005 ]
						then
							HORA="09"
				fi
		esac
	done
