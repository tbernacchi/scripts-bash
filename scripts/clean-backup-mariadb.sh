#!/bin/bash 
MYSQL_BACKUP="/backups-infra/bds/wiki_mariadb" 

clean_bkp() {
	/usr/bin/find $MYSQL_BACKUP -type f -ctime +7 -exec rm '{}' ';'
}
clean_bkp 
