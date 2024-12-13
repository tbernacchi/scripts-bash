#!/bin/bash
USER="root" 
HOST_BACKUP="zipado01.tabajara.intranet"
DATE="$(date +%d-%m-%Y)"
BACKUP_MARIA="/root/backups/bds/wiki_mariadb" 
BACKUP_REMOTE="/backups-infra/bds/wiki_mariadb"

mysql_dump() { 
	/usr/bin/mysqldump -u root -pMudar@123 --all-databases > "${BACKUP_MARIA}"/all_mariadb-"${DATE}".sql
} 

tar_db() { 
	/usr/bin/tar czf wiki-mariadb-backup-"${DATE}".tar.gz "${BACKUP_MARIA}"/all_mariadb-"${DATE}".sql 2> /dev/null
} 

copy_bkp() { 
	/usr/bin/scp -qpr wiki-mariadb-backup-"${DATE}".tar.gz "${USER}"@"${HOST_BACKUP}":"${BACKUP_REMOTE}" 2> /dev/null
} 

mv_bkp() { 
	/usr/bin/mv wiki-mariadb-backup-"${DATE}".tar.gz "${BACKUP_MARIA}"
} 
mysql_dump
tar_db
copy_bkp
mv_bkp 
