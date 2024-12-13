#!/bin/sh

# Script que faz o update do repositorio interno
# Valida se existe arquivo novo no repositorio e executa o create repo com o comps.xml

# como gerar o comps.xml
# yum-groups-manager -n "Pacotes Dev tabajara" --id=devpkgs --save=/var/www/html/prod/tabajarapackages/comps.xml

LOCK="/tmp/repo.lck"

PID="$$"

fn_createrepo()
	{
	 createrepo /var/www/html/prod/tabajarapackages/ -g /var/www/html/prod/tabajarapackages/comps.xml
	}

fn_check_update_file()
	{
	 TTPKS=`find /var/www/html/prod/tabajarapackages/ -maxdepth 1 -type f -cmin -6 | wc -l`

	 # Valida que exitem pacotes mais recentes que 6 minutos (cron em ate 5 minutos)	
	 if [ $TTPKS -gt 0 ]
		then
		    fn_createrepo 
	 fi
	}

fn_check_lock()
        {
         if [ -e $LOCK ]
            then
                ps -p `echo $PID` | grep [0-9]
                if [ $? -eq 0 ]
                   then
                       echo "Arquivo de lock $LOCK encontrado, saindo..."
                       exit 0
                fi
            else
                 echo $PID > $LOCK
                 fn_check_update_file
          fi
         }


fn_check_lock

# removemos o lock
rm $LOCK

