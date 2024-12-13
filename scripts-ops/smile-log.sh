#!/bin/bash 
ROOTSIZE="$(df -h / | sed ':a;$!N;s/\n/|/g;ta' | awk '{ print $11 }' | sed -e 's/%//g')"

if [ $ROOTSIZE -ge 75 ];then 
	LARGEFILES="$(find /var/log -type f -cmin -5 -size +2G)"
 		for i in `echo $LARGEFILES`;do 
		:> $i 
		done  	
fi

