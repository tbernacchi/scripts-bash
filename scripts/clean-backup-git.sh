#!/bin/bash 
BKP="/var/opt/gitlab/backups/"
FULL="/backup-git/"

clean_bkp_git()
        {
        /usr/bin/find $BKP $FULL -type f -ctime 7 -exec rm '{}' ';'
        }
clean_bkp_git
