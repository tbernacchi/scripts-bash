#!/bin/sh

newuser="$2"

DT=`date +%%d-%m-%Y`

DIR_ROOT="/SFTP/"

PATH_USER="$newuser/$newuser"

fn_valida_user()
	{
        grep $newuser /etc/ssh/sshd_config	
	RESULT=`echo $?`

	if [ $RESULT == 0 ]
		then
			tput setaf 1; echo "Usuario $newuser ja esta no SSHD, saindo!!!"
			exit
		else
			fn_cria_home
	fi
	}

fn_cria_home()
	{
	mkdir -p /SFTP/$newuser/$newuser

	chmod 770 /SFTP/$newuser/$newuser
	chown $newuser /SFTP/$newuser/$newuser
	
	grep $newuser /etc/ssh/sshd_config
	RESULT=`echo $?`

	if [ $RESULT != 0 ]
		then
			cp /etc/ssh/sshd_config /etc/ssh/sshd_config-$DT

echo -n "##              ##
# Configuracoes para acesso de usuarios
Match User username
        # ChrootDirectory %h
        ChrootDirectory /SFTP/%u
        ForceCommand internal-sftp
        X11Forwarding no
        AllowTcpForwarding no
        AllowAgentForwarding no
        PermitTunnel no
        PermitTTY yes
" | sed "s/username/$newuser/g" >> /etc/ssh/sshd_config 
	
			systemctl restart sshd
		else
			echo "ja esta no ssh"
	fi
	}

fn_help()
  {
   echo ""
   echo "execute: $0 <add>espaco<USER_NAME>"
   echo ""
   exit 0

  }

case $1 in
	add)
              	fn_valida_user
        ;;

        *)
                fn_help
    	;;
esac
