#!/bin/bash 
cp -pr /repo/pacotes/tabajarapackages-qa/"$1"-"$2".noarch.rpm /repo/pacotes/tabajarapackages && sh -x /usr/local/bin/repo/create-repo-dev-2-prod.sh
