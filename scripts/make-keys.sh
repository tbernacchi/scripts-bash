#!/bin/sh

# Script adaptado para tratar quando tem o mesmo usuario com senha diferente no ambiente
# a versao original executava globalmente, mas a IBM nao tem um padrao
# Autor: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com

DIR_PROJECT="/var/rundeck/projects"

# Keydb (entregue via chef)
KEYDB="/var/rundeck/keys/keylist.db"

# Arquivo temporario
BASE_TEMP=`mktemp --suffix=-KEYNEW`

fn_endpoint()
  {
  # Endpoint do Rundeck
  export RD_URL=http://rundeck.tabajara.intranet:4440
  export RD_USER=svc_zabbix_monit
  export RD_PASSWORD="kwf4384R?"
  }


fn_make_list()
  {
  fn_endpoint

  for KEYPATH in `grep username $DIR_PROJECT/* -r -A1 | grep "ssh-password-storage-path" | cut -f2 -d'"' | sort -u`
    do
      USERNODE=`echo $KEYPATH | cut -f3 -d"/" | sed 's/user-//g'`
      echo "user $USERNODE e path $KEYPATH"

      cat $KEYDB | grep ^$USERNODE | awk -F'|' '{ print $2 }' > $BASE_TEMP

      find /var/lib/rundeck/var/storage/content/$KEYPATH > /dev/null
      RESULT=`echo $?`

      if [ $RESULT == 0 ]
        then
          /usr/bin/rd keys update --file $BASE_TEMP --type password --path $KEYPATH
          fn_gc
        else
          /usr/bin/rd keys create --file $BASE_TEMP --type password --path $KEYPATH
          fn_gc
      fi

    done
  }

fn_gc()
  {
  rm -f $BASE_TEMP
}

fn_make_list
