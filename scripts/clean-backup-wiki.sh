#!/bin/bash 
MYSQL_BACKUP="/root/backups/bds/wiki_mariadb" 

clean_bkp() {
	/usr/bin/find $MYSQL_BACKUP -type f -ctime +7 -exec rm '{}' ';'
}
clean_bkp 
