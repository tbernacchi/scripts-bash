#!/bin/bash
PACKAGE="chef-server-core-12.17.33-1.el7.x86_64.rpm"
PACKAGE_URL="http://repo.tabajara.intranet/pacotes/base/chef/"
BACKUP_HOST="zipado01.tabajara.intranet" 
PASSWD="mudar123" 

#ssh-pass
if [ -e "/usr/bin/sshpass" ];then
	echo "ssh-pass already installed..."
else 
	echo "Installing sshpass..."
	yum install -y sshpass > /dev/null
fi 

#Generating ssh-key
echo "Generating ssh-key..."
if [ `ls -A /root/.ssh | wc -l` == 0 ];then 
	echo "Creating ssh-key..."
	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa > /dev/null
else 
	echo "Copying ssh-key to ${BACKUP_HOST}..." 
	echo "${PASSWD}" > filename
	/usr/bin/sshpass -f filename ssh-copy-id root@"${BACKUP_HOST}"
	rm -f filename
fi

#Last chef-server-ctl backup and keys
LAST_BKP1="$(/usr/bin/ssh root@"${BACKUP_HOST}" ls -t /backups-infra/chef/chef-server-ctl | head -n1)" 
LAST_BKP2="$(/usr/bin/ssh root@"${BACKUP_HOST}" ls -t /backups-infra/chef/keys| head -n1)"

#Creating keys directory
echo "Creating directories..."
mkdir -p /root/keys
mkdir -p /root/backup-keys
mkdir -p /root/backup-chef-server-ctl

#Copying last backup
echo "Copying last backup of chef-server-ctl..."
/usr/bin/scp -qpr root@"${BACKUP_HOST}":/backups-infra/chef/chef-server-ctl/"${LAST_BKP1}" /root/backup-chef-server-ctl 
echo "Copying last backup of chef-server keys..."
/usr/bin/scp -qpr root@"${BACKUP_HOST}":/backups-infra/chef/keys/"${LAST_BKP2}" /root/backup-keys
echo "Copying users.txt..."
/usr/bin/scp -qpr root@"${BACKUP_HOST}":/backups-infra/chef/users.txt . 
echo "Copying create_users.sh"
/usr/bin/scp -qpr root@"${BACKUP_HOST}":/backups-infra/chef/create_users.sh . 

#Extracting keys
echo "Extracting keys..."
tar xzf /root/backup-keys/"${LAST_BKP2}" -C /root/keys/

#Download package
/usr/bin/wget "${PACKAGE_URL}${PACKAGE}" -P /usr/local/src

#Install
/usr/bin/rpm -i /usr/local/src/"${PACKAGE}" --quiet

#Reconfigure
/usr/bin/chef-server-ctl reconfigure

#rsync
if [ -e "/usr/bin/rsync" ];then
	echo "rsync already installed..."
else 
	echo "Installing rsync..."
	yum install -y rsync > /dev/null
fi 

#Restore chef-server
/usr/bin/chef-server-ctl restore /root/backup-chef-server-ctl/"${LAST_BKP1}" 

#Adding users to their org's
ORGS="$(chef-server-ctl org-list)"
CHEF_USERS="$(chef-server-ctl user-list | grep -v pivotal)"  

for username in `echo $CHEF_USERS`;do 
	for org in `echo $ORGS`;do
	chef-server-ctl org-user-add $org $username > /dev/null 
	done 
chef-server-ctl grant-server-admin-permissions $username
done

mv `ls | grep opscode` /usr/local/src 
