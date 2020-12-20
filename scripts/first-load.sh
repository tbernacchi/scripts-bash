#!/bin/sh

# PATH cookbook
COOKPATH=`cat ~/.chef/knife.rb  | grep cookbook | cut -f2 -d"'"`

# COOK RUNDECK/projects
PRJS="stl-rundeck/files/projects"
RECIPE="stl-rundeck/recipes/create-project.rb"

NAME="$2"

fn_check_name()
  {
  grep $NAME $COOKPATH/$RECIPE > /dev/null
  RESULT=`echo $?`

  if [ $RESULT -eq 0 ]
    then
      PRJ=`echo $NAME | tr '[:lower:]' '[:upper:]'`
      scp -rv rundeck.tabajara.intranet:/var/rundeck/projects/$PRJ $COOKPATH/$PRJS
    else
      echo "Projeto nao esta na recipe $RECIPE"
  fi
  }

fn_help()
  {
    echo " "
    echo "execute: $0 <prj>espaco<project_name>"
    echo " "
    exit 0
  }

case $1 in
    prj)
        fn_check_name
    ;;

    *)
      fn_help
    ;;

esac
