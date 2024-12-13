#!/bin/sh

# removendo o proxy

unset http_proxy
unset https_proxy

DIR="/usr/local/bin/check-time-so-java/"

FILE_JAVA="monitjavatime"

CONFFILE="/etc/zabbix/zabbix_agentd.conf"

cd $DIR

test -e $FILE_JAVA.class

RESULT_FILE=`echo $?`

# Baixamos o arquivo class

if [ $RESULT_FILE != 0 ]
        then
                wget http://repo.tabajara.local/pacotes/horarioverao/validator/$FILE_JAVA.class
fi

# Validacoes
# A data do SO
SO_DT=`date +%s`
echo "SO_DT $SO_DT"

# A data do JAVA

# Se nao tiver o java envia a data do SO para nao gerar stale
which java  > /dev/null 2>&1

RESULT=`echo $?`

if [ $RESULT == 1 ]
        then
                # envio do time do java fake, pois nao tem java
                JAVA_DT=$SO_DT
                echo "JAVA_DT $JAVA_DT"
        else
                JAVABIN=$(which java)
                JAVA_DT=`$JAVABIN $FILE_JAVA`
                echo "JAVA_DT $JAVA_DT"
fi
