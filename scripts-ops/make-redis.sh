#!/bin/sh

# Script para recuperar para o Redis em caso de crash geral de todos os servidores
# Observe que este script está com os IP do atual ambiente de producao.

redis-cli --cluster create 10.150.226.172:6379 10.150.226.173:6379 10.150.226.174:6379 10.150.226.187:6379 10.150.226.188:6379 10.150.226.189:70006379 --cluster-replicas 1
