#!/bin/bash
# Simple script to backup Wordpress public_html files and database!
## You must set your IP address on your local machine;
## Copy ssh public key to your hosting provider;
## Made on Fedora and send the final backup file to Dropbox!
TODAY="$(date +%m_%d_%Y)"
DIRTOBKP="/home/tadeubernacchi/public_html"
BKPDEST="/tmp/backup-wordpress"
FULLBKP="backup_meusite"
IP="$(nslookup tadeubernacchi.com.br| tail -n2 \
| head -n1| awk  '{ print $2 }')"

#CHECK IP!
if [ -z "${IP}" ];then 
	echo "ERROR: IP address not found!"
exit 1
fi

#CHECK BACKUP DESTINY!
if [ -d "${BKPDEST}" ];then 
	echo "Backup destiny already exist, skipping..."
else
	echo "Backup destiny not found, creating..."
	mkdir -p "${BKPDEST}"
fi 

#SSH INTO SERVER!
ssh tadeubernacchi@"${IP}" /bin/bash << EOF
	echo "Connected to remote host..."
	echo "Zipping public_html files..."
	zip -qr backup-"${TODAY}"_public_html.zip public_html/ 2> /dev/null
	#tar -c --force-local -f backup-"${TODAY}"_public_html.tar.gz public_html/ 2> /dev/null
	echo "Backing up database..."
	mysqldump -u tadeu -pSENHADOIDA bkp_2018 > backup-"${TODAY}"_database.sql 2> /dev/null
	echo "Making a full backup..."
	if [ -f backup-"${TODAY}"_public_html.zip ] && [ backup-"${TODAY}"_database.sql ];then 		
		tar -cz --force-local -f "${FULLBKP}"_"${TODAY}".tar.gz backup-"${TODAY}"_public_html.zip backup-"${TODAY}"_database.sql	 
	fi	
	#backup dir must exist!
	mv 	backup-"${TODAY}"_public_html.zip backup-"${TODAY}"_database.sql backup/
EOF

echo "Copying remote backup to localhost..." 
scp -qpr tadeubernacchi@"${IP}":"${FULLBKP}"_"${TODAY}".tar.gz "${BKPDEST}"

cd "${BKPDEST}"
cp -pr "${FULLBKP}"_"${TODAY}".tar.gz /tmp

if [ -f /tmp/"${FULLBKP}"_"${TODAY}".tar.gz ];then 
	ssh tadeubernacchi@"${IP}" /bin/bash << EOF
	/bin/rm -f "${FULLBKP}"_"${TODAY}".tar.gz
EOF
fi

echo "Done!"
