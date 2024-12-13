#!/bin/bash

# Script para remover volumes que nao possuem dados no catalogo.
# use com muita atencao

cd /volumes-bacula/backup
for i in `find . -maxdepth 1 -type f -printf "%f\n"`; do
  echo "list volume=$i" | bconsole | if grep --quiet "No results to list"; then
        echo "$i is ready to be deleted"
  	rm -f /mnt/bacula/default/$i
  fi
done

