#!/bin/bash
CIP_SAIDA='/jobs/prd/CIP/saida/'
CIP_PROCESS='/opt/silocarquivos/cip/saida/proces/'
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
LOG_ERRO='/opt/silocarquivos/logs/transfer_files.err'
LIST='/opt/silocarquivos/scripts/lists/siloc_saida.list'
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | awk -F'=' '{print $NF}')
/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k job_siloc_to_cip -o 1
set -x
if [ $(stat -c%s $LIST) -ne 0 ]
    then
        for fname in $(cat $LIST)
        do
            c_1="$(cat $fname | wc -c)"
            sleep 15
            c_2="$(cat $fname | wc -c)"
            if [[ $c_1 -eq $c_2 ]]
                then
                cp $fname $CIP_SAIDA 2>> $LOG_ERRO
                if [ $? -eq 0 ]
                then
                    faslc=$(echo $fname | awk -F'/' '{print $NF}')
                    sudo sed -i '/'$faslc'/d' $LIST 2>> $LOG_ERRO
                    mv $fname $CIP_PROCESS
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - siloc-to-cip - [INFO] Arquivo $faslc movido para o Connect Direct com sucesso" >>  $LOG_FILE
                else
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - siloc-to-cip - [ERROR] Falha ao enviar $fascl a pasta do Connect Direct" >>  $LOG_FILE
                fi
            else
                faslc=$(echo $fname | awk -F'/' '{print $NF}')
                echo "`date +"%Y-%m-%d %H:%M:%S"` - siloc-to-cip - [INFO] O Arquivo $faslc esta em uso e nao sera movido agora - SIZE $c_1 -> $c_2" >>  $LOG_FILE
            fi
        done
fi
