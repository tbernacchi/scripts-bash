#!/bin/sh

# Script para criacao de projeto no Rundeck
# Usando o cliente do Rundeck "rd" executa a busca do nome (string) do project na estrutura:
# /var/rundeck/projects
# em caso de nao existir o projeto nesta estrutura, executa a criacao e a populacao do arquivo resources.xml
# com a primeira configuracao, bastando continuar a preparacao dos nodes e suas chaves

# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# 01/05/2019

# Arquivo temporario
PROP_TEMP=`mktemp --suffix=-PRJNEW`

# Comandos e parametros
CMD_CREATE="rd projects create -p"
PARAMS="--file $PROP_TEMP"

# O nome do projeto passado como parametro
NEW_PRJ="$2"

# Tratamos o nome para padronizar tudo em caixa alta
NEW_NOME=`echo $NEW_PRJ | tr '[:lower:]' '[:upper:]'`

# Diretorios de projetos
DIR_PRJS="/var/rundeck/projects"

DT=`date "+no dia %d do %m em %Y as %H e %M minutos"`

# Endpoint do Rundeck
export RD_URL=http://zonzo04.tabajara.intranet:4440
export RD_USER=svc_zabbix_monit
export RD_PASSWORD="kwf4384R?"

fn_valida_project()
	{
	test -d $DIR_PRJS/$NEW_NOME
	RESULT=`echo $?`
	
	if [ $RESULT == 0 ]
		then
			tput setaf 1; echo "Projeto ja $NEW_NOME existe, verifique a configuracao, saindo!!!"
			exit
		else
			fn_create_project
	fi
	}

fn_create_project()
	{
	mkdir $DIR_PRJS/$NEW_NOME/etc -p
        chown rundeck:rundeck $DIR_PRJS/$NEW_NOME -R

echo -n "#Exported configuration
#Wed May 01 08:20:34 BRT 2019
project.description="Criado pelo Chef em $DT"
project.disable.executions=false
project.disable.schedule=false
project.gui.motd.display=projectList,projectHome
project.gui.readme.display=projectList,projectHome
project.jobs.gui.groupExpandLevel=1
project.label=PRJALVOSED
project.name=PRJALVOSED
project.ssh-authentication=privateKey
project.ssh-command-timeout=0
project.ssh-connect-timeout=0
project.ssh-keypath=/var/lib/rundeck/.ssh/id_rsa
resources.source.1.config.file=/var/rundeck/projects/PRJALVOSED/etc/resources.xml
resources.source.1.config.format=resourcexml
resources.source.1.config.generateFileAutomatically=true
resources.source.1.config.includeServerNode=true
resources.source.1.type=file
service.FileCopier.default.provider=jsch-scp
service.NodeExecutor.default.provider=jsch-ssh" | sed "s/PRJALVOSED/$NEW_NOME/g" > $PROP_TEMP

	# Criando o projeto em si
	$CMD_CREATE $NEW_NOME $PARAMS
	
	# Criando o resource
echo -n '<?xml version="1.0" encoding="UTF-8"?>
<project>
<node name="exemplo-node.tabajara.intranet"
	description="Servidor de Exemplo"
        tags="Generico"
        hostname="exemplo-node.tabajara.intranet"
        osName="Linux"
        username="root"
        ssh-password-storage-path="keys/nodes/exemplo-node.tabajara.intranet"
        ssh-authentication="password"/>
</project>' | sed "s/PRJALVOSED/$NEW_NOME/g" > $DIR_PRJS/$NEW_NOME/etc/resources.xml

	# clean
	fn_gc

	}
fn_gc()
	{
	rm -f $PROP_TEMP
	}

fn_help()
	{
	echo " "
	echo "execute: $0 <add>espaco<project_name>"
	echo " "
	exit 0
	}

case $1 in
	add)
		fn_valida_project
	;;

	*)
		fn_help
	;;
esac		 
