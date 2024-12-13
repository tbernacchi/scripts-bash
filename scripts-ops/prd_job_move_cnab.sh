#!/bin/bash
CNAB_DIR='/jobs/prd/liquidacao/input/'
CNAB_DIR_PROCS='/jobs/prd/liquidacao/process/'
PWARE='/opt/silocarquivos/payware/entrada/'
MATERA='/jobs/prd/CONKD0001/input/'
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
LOG_ERR='/opt/silocarquivos/logs/transfer_files.err'
LIST='/opt/silocarquivos/scripts/lists/cnab.list'
FLAG='/opt/silocarquivos/scripts/lists/DebFlag'
LOCK_FILE='/opt/silocarquivos/scripts/.cnab-move.lock'
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | awk -F'=' '{print $NF}')
/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k job_move_cnab -o 1

function debito {
if  [ $(stat -c%s $LIST) -ne 0 ]
     then
	for fname in $(cat $LIST)
        do
	    if [[ "$fname" == *SUBQ_LIQ_23_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_02_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_04_COBK_* ]]
	    then
		cnab=$(echo $fname | awk -F'/' '{print $NF}')
                c_1="$(cat $fname | wc -c)"
		sleep 5
                c_2="$(cat $fname | wc -c)"

                if [[ $c_1 -eq $c_2 ]]
		then
                    cp $fname $PWARE 2>> $LOG_ERR
                    if [ $? -eq 0 ]
                    then
			sudo sed -i '/'$cnab'/d' $LIST 2>> $LOG_ERR
                        mv $fname $CNAB_DIR_PROCS 2>> $LOG_ERR
                        echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [INFO] [Debito] Arquivo cnab $cnab movido para o payware com sucesso" >>  $LOG_FILE
			echo 1 > $FLAG
		    else
                        echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [ERROR] [Debito] Falha ao enviar $cnab a pasta o payware" >>  $LOG_FILE
		    fi
		fi
	     fi
	done
fi
}


function credito {
if [[ $(stat -c%s $LIST) -ne 0 ]] && [[ $(cat $FLAG) -eq 0 ]]
    then
        for fname in $(cat $LIST)
        do
            if [[ "$fname" == *SUBQ_LIQ_27_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_28_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_24_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_22_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_01_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_03_COBK_* ]]
            then

                cnab=$(echo $fname | awk -F'/' '{print $NF}')
                c_1="$(cat $fname | wc -c)"
                sleep 5
                c_2="$(cat $fname | wc -c)"
                if [[ $c_1 -eq $c_2 ]]
                    then
	            cp $fname $PWARE/credito 2>> $LOG_ERR
                    if [ $? -eq 0 ]
                    then
                        sudo sed -i '/'$cnab'/d' $LIST 2>> $LOG_ERR
                        mv $fname $CNAB_DIR_PROCS 2>> $LOG_ERR
                        echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [INFO] Arquivo cnab $cnab movido para o payware/credito com sucesso" >>  $LOG_FILE
                    else
                        echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [ERROR] Falha ao enviar $cnab a pasta o payware/credito " >>  $LOG_FILE
                    fi
                else
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [INFO] O Arquivo $cnab esta em uso e nao sera movido agora." >>  $LOG_FILE
                fi
	    elif [[ "$fname" == *SUBQ_LIQ_23_COBK_*  ]] || [[ "$fname" == *SUBQ_LIQ_02_COBK_* ]] || [[ "$fname" == *SUBQ_LIQ_04_COBK_* ]]
		then
		debito
            else
                cnab=$(echo $fname | awk -F'/' '{print $NF}')
		c_1="$(cat $fname | wc -c)"
                sleep 5
                c_2="$(cat $fname | wc -c)"
                sudo sed -i '/'$cnab'/d' /opt/silocarquivos/scripts/lists/cnab_time.list
		if [ $c_1 -eq $c_2 ]
                then
                    cp $fname $MATERA 2>> $LOG_ERR
		                sudo chown cdadm: $MATERA/$cnab
                    if [[ $? -eq 0 ]]
                    then
                        sudo sed -i '/'$cnab'/d' $LIST 2>> $LOG_ERR
                        mv $fname $CNAB_DIR_PROCS 2>> $LOG_ERR
                        echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [INFO] [MATERA] Arquivo cnab $cnab movido para o matera com sucesso " >>  $LOG_FILE
                    else
                        echo "`date +"%Y-%m-%d %H:%M:%S"` - cnab-move - [ERROR] [MATERA] Falha ao enviar $cnab para a pasta do matera " >>  $LOG_FILE
                    fi
                fi
            fi
        done
fi
}

if [ -e $LOCK_FILE ]
then
	exit 0
else
	touch $LOCK_FILE
	debito
	sleep 180
        credito
	rm -rf $LOCK_FILE
	if [[ $(ls -l $PWARE/*SUBQ_LIQ_23_COBK* | wc -l 2> /dev/null) -gt 0 ]] || [[ $(ls -l $PWARE/*SUBQ_LIQ_02_COBK* | wc -l 2> /dev/null) -gt 0 ]] || [[ $(ls -l $PWARE/*SUBQ_LIQ_04_COBK* | wc -l 2> /dev/null) -gt 0 ]]

	then
		echo 0 > $FLAG
		exit 0
	else
       		credito
		echo 0 > $FLAG
	fi
fi
