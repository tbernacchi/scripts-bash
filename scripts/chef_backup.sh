#!/bin/bash
USER="root" 
DATE="$(date +%d-%m-%Y-%H-%M)" 
USERS="$(chef-server-ctl user-list | grep -v pivotal)"
HOST_BACKUP="zipado01.tabajara.intranet"
BACKUP_KEYS="/root/backup-chef/keys"
BACKUP_CHEF="/root/backup-chef/chef-server-ctl"

#Cleaning users.txt
ssh root@zipado01.tabajara.intranet "> /root/backup-chef/users.txt"

#Copying create_users.sh
echo "Copying create_users.sh..."
scp -qpr create_users.sh "${USER}"@"${HOST_BACKUP}":/root/backup-chef

echo "Backing up keys..."
tar czf Backup-Chef-Keys-"${DATE}".tar.gz -C /root/keys/ . 2> /dev/null 

echo "Copying keys..."
scp -qpr Backup-Chef-Keys-"${DATE}".tar.gz "${USER}"@"${HOST_BACKUP}":"${BACKUP_KEYS}" 2> /dev/null
mv Backup-Chef-Keys-"${DATE}".tar.gz /root/backup-keys/ 

#Backing up the chef-server
echo "Starting chef-server-ctl backup..."
chef-server-ctl backup --yes > /dev/null

echo "Coping chef-server-ctl backup..." 
scp -qpr /var/opt/chef-backup/`ls -t /var/opt/chef-backup/ | head -n1` "${USER}"@"${HOST_BACKUP}":"${BACKUP_CHEF}"

#Users list
echo "Creating users list..."
for i in `echo $USERS`;do
	USERS_SHOW=$(chef-server-ctl user-show $i | egrep 'username|display_name|email' | awk '{ print $2,$3 }'|xargs -n4)
	while read -r line;do
	ssh "${USER}"@"${HOST_BACKUP}" "echo '$line' >> /root/backup-chef/users.txt"
	done <<< "$USERS_SHOW"
done
echo "Done!"
