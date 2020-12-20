#!/bin/bash
CIP_ENT_RETORNO='/jobs/prd/CIP/entrada/retorno'
CIP_ENT_PROCESSED='/jobs/prd/CIP/entrada/retorno/processed'
SILOC_CONCILIACAO='/opt/silocarquivos/conciliacao/entrada/'
LOG_FILE='/opt/silocarquivos/logs/transfer_files.log'
LOG_ERRO='/opt/silocarquivos/logs/transfer_files.err'
LIST='/opt/silocarquivos/scripts/lists/retorno_ret.list'
ZBXPRX=$(grep ServerActive /etc/zabbix/zabbix_agentd.conf | awk -F'=' '{print $NF}')
#/bin/zabbix_sender -z $ZBXPRX -s vintws001.tabajaradc.local -k job_retorno_ret -o 1
if [ $(stat -c%s $LIST) -ne 0 ]
    then
        for fname in $(cat $LIST)
        do
            c_1="$(cat $fname | wc -c)"
            sleep 10
            c_2="$(cat $fname | wc -c)"
            if [[ $c_1 -eq $c_2 ]]
                then
                cp $fname $SILOC_CONCILIACAO 2>> $LOG_ERRO
                if [ $? -eq 0 ]
                then
                    faslc=$(echo $fname | awk -F'/' '{print $NF}')
                    sudo sed -i '/'$faslc'/d' $LIST 2>> $LOG_ERRO
                    mv $fname $CIP_ENT_PROCESSED
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - retorno-ret - [INFO] Arquivo $faslc movido para o diretorio de conciliacao retorno com sucesso" >>  $LOG_FILE
                    sudo sed -i '/'$faslc'/d' $LIST
                else
                    echo "`date +"%Y-%m-%d %H:%M:%S"` - retorno-ret - [ERROR] Falha ao enviar $fascl a pasta de conciliacao retorno" >>  $LOG_FILE
                fi
            else
                faslc=$(echo $fname | awk -F'/' '{print $NF}')
                echo "`date +"%Y-%m-%d %H:%M:%S"` - retorno-ret - [INFO] O Arquivo $faslc esta em uso e nao sera movido agora - SIZE $c_1 -> $c_2" >>  $LOG_FILE
            fi
        done
fi
