#!/bin/sh

# Script para copiar os relatorios locais da Tabajara para o TWS para transferencia via Connect
# Data: 03/05/2019
# Autor: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com


DIR_LOCAL="/jobs/relatorio-tabajara-full"
DIR_COPY="/jobs/relatorio-tabajara-full/copy"

DIR_REMOTO="/connect/jobs/TABAJARA"
DIR_PROCESS_REMOTO="/connect/jobs/TABAJARA/process"

for file in `find $DIR_LOCAL -maxdepth 1 -type f \( -name "BASE_TABAJARA*" -o -name "TABAJARA*" \)`
	do
		cp $file $DIR_REMOTO/
		RESULT=`echo $?`

		if [ `echo $?` == 0 ]
			then
				mv $file $DIR_COPY/
		fi
	done



