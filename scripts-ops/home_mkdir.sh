#!/bin/bash
cd /home
for a in `getent group infraestrutura_admin | cut -f4 -d":" | sed 's/,/ /g'`; do 
	mkdir $a; chown $a: $a 
	cp -pr /etc/skel/.bash_logout  /etc/skel/.bash_profile /etc/skel/.bashrc $a
done
