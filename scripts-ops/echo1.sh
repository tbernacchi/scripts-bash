#!/bin/bash
ETH1="$(ifconfig eth1 | grep -v inet6 | grep inet| awk '{ print $2}')"
echo $ETH1 
