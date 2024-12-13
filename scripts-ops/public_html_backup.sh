#!/bin/bash
USER="root" 
HOST_BACKUP="zipado01.tabajara.intranet"
DATE="$(date +%d-%m-%Y-%H-%M)"
DIR="/var/www/Institucional/public_html"
BACKUP_PUBLIC="/backups-infra/public_html"

#Backup public_html 
tar czf public-html-backup-"${DATE}".tar.gz "${DIR}" 2> /dev/null

#Copy backup to remote host
scp -qpr public-html-backup-"${DATE}".tar.gz "${USER}"@"${HOST_BACKUP}":"${BACKUP_PUBLIC}" 2> /dev/null

mv public-html-backup-"${DATE}".tar.gz /root/public_html_backup 
