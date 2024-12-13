#!/bin/bash
#Put on /etc/cron.d/clean_backup_chef
##SHELL=/bin/bash 
##PATH=/sbin:/bin:/usr/sbin:/usr/bin 
##0 0 * * * root /usr/local/bin/clean_backup_chef.sh >/dev/null 2>&1
CSKEYS="/backups-infra/chef/keys" 
CSCTL="/backups-infra/chef/chef-server-ctl/" 

cl_old_bkp()
        {
        /usr/bin/find $CSCTL -type f -ctime +7 -exec rm '{}' ';'
        /usr/bin/find $CSKEYS -type f -ctime +7 -exec rm '{}' ';'
        }
cl_old_bkp 
