#!/bin/bash
## Knife ssh with two commands - It need OS_PASSWORD exported!
HOSTS=$(knife node list | grep $1)
COMAND=$2
while read x;do
knife ssh "fqdn:$x" "echo '$OS_PASSWORD' | sudo -S -p '' sudo $COMAND" -P $OS_PASSWORD
done <<< "$HOSTS"
