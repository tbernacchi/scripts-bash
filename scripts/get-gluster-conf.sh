#!/bin/sh

BACK_DIR="/var/backup/gluster"

DT=`date +%d-%m-%Y`

VOLS=`gluster vol list`

for vol in `echo $VOLS`
  do
     gluster vol info $vol > $BACK_DIR/$vol-$DT     
  done


