#!/bin/bash
SILOC_ENTRADA='/opt/silocarquivos/cip/entrada/'
CIP_PROCESS='/jobs/prd/CIP/entrada/proces'
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
LOG_ERRO='/opt/silocarquivos/logs/transfer_files.err'
LIST='/opt/silocarquivos/scripts/lists/cd_retorno.list'
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | awk -F'=' '{print $NF}')
/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k job_cip_to_siloc -o 1
if [ $(stat -c%s $LIST) -ne 0 ]
    then
        for fname in $(cat $LIST)
        do
            c_1="$(cat $fname | wc -c)"
            sleep 5
            c_2="$(cat $fname | wc -c)"
            if [[ $c_1 -eq $c_2 ]]
                then
                cp $fname $SILOC_ENTRADA 2>> $LOG_ERRO
                if [ $? -eq 0 ]
                then
                    faslc=$(echo $fname | awk -F'/' '{print $NF}')
                    sudo sed -i '/'$faslc'/d' $LIST 2>> $LOG_ERRO
                    sudo mv $fname $CIP_PROCESS 2>> $LOG_ERRO
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - cip-to-siloc - [INFO] Arquivo $faslc movido para o Siloc com sucesso" >>  $LOG_FILE
                else
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - cip-to-siloc - [ERROR] Falha ao enviar $fascl a pasta do Siloc" >>  $LOG_FILE
                fi
            else
                echo "`date +"%Y-%m-%d %H:%M:%S"` - cip-to-siloc - [INFO] O Arquivo $faslc esta em uso e nao sera movido agora" >>  $LOG_FILE
            fi
        done
fi
