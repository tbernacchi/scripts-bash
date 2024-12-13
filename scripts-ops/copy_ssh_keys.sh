#!/bin/bash

# Lista de endereços IP das máquinas remotas
REMOTE_HOSTS=("192.168.0.102" "192.168.0.103" "192.168.0.104" "192.168.0.105" "192.168.0.106")

# Loop através da lista de endereços IP
for host in "${REMOTE_HOSTS[@]}"
do
    echo "Copying SSH key to $host"
    ssh-copy-id tadeu@$host
done

