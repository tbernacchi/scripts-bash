#!/bin/bash 
SIZE=$(du -sh * | grep -v Dropbox | grep -v Downloads | grep -v 'VirtualBox VMs'| grep -v backup | \
grep -v Cookbooks-WM | awk '{ print $2 }' | xargs du -sc | grep total|awk '{ print $1 }')
DIR=$(du -sh * | grep -v 'G' | grep -v Dropbox | grep -v backup | grep -v Cookbooks-WM | \
awk '{ print $2 }' | xargs du -ach -d 0| grep -v total | awk '{ print $2 }')
DROPBOX="/home/tadeu/Dropbox/Backup_HP_Notebook"

if [ "${SIZE}" -le 1000000 ];then 
	for i in `echo "$DIR"`;do 
 	cp -prR $i "${DROPBOX}" 2> /dev/null
 	done
echo "Copying files to Dropbox..."
else 
echo "All files are larger than 1GB, exiting..."
exit 1 
fi
	
