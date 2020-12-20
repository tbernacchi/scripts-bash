#!/bin/bash
#Users must be with '-'!!! 
#You should fill out the requirements on users.txt
#i.e: Name Lastname email@tabajara.com.br name-lastname

#Proxy
export http_proxy=http://proxy.tabajara.intranet:3128
export https_proxy=http://proxy.tabajara.intranet:3128

#QA and PROD keys
QA_KEY="/root/keys/qa-tabajara-validator.pem"  
PROD_KEY="/root/keys/prod-tabajara-validator.pem" 

#USER
USER="$(cat users.txt | awk '{ print $4 }')" 

echo "Creating user..."
while read name lastname email username;do
	chef-server-ctl user-create $username $name $lastname $email 'Password@123' --orgname tabajara --filename /root/keys/$username.pem 2> /dev/null
done < users.txt

echo "Adding user to qa-tabajara and prod-tabajara organization..."

#Add users on the environments
chef-server-ctl org-user-add prod-tabajara "${USER}" 
chef-server-ctl org-user-add qa-tabajara "${USER}" 

#keys.zip
cd /root/keys 
/usr/bin/zip -jr keys.zip $USER.pem $QA_KEY $PROD_KEY 2>&1 > /dev/null
mv keys.zip /root/ 

#SLACK 
USERNAME=${1}
shift

if [ -z ${USERNAME} ]; then
  echo "ERROR: Usage: ${0} <username>"
  exit 1
fi

#Slack token
SLACK_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#Get User ID Slack
USER_ID_SLACK=$(curl \
    --stderr /dev/null \
    -d "token=${SLACK_TOKEN}" \
    https://tabajara.slack.com/api/users.list \
    | jq -r '.members[] | select(.name == "'${USERNAME}'") | .id'
)

#User tr
USERTR="$(echo $USER| sed 's/\-/ /g' | awk '{ print $1 }')" 

echo "Sending credentials to user $USERNAME..."
 
curl -s -F "initial_comment=Hello "${USERTR^}" 

Your account on our Chef-server was created ("${USER}"). You can download your keys below:" -F file=@/root/keys.zip -F channels=$USER_ID_SLACK -H "Authorization: Bearer $SLACK_TOKEN" https://slack.com/api/files.upload > /dev/null 

SLACK_MESSAGE="

For more information on how to set up your environment please follow the link:

http://wiki.tabajara.intranet/infrawiki/index.php/Chef#knife.rb

See ya!
"

curl \
  -s \
  --stderr /dev/null \
  -d "token=${SLACK_TOKEN}" \
  -d "channel=$USER_ID_SLACK" \
  -d "as_user=true" \
  -d "unfurl_links=true" \
  -d "text=${SLACK_MESSAGE}" \
   https://tabajara.slack.com/api/chat.postMessage > /dev/null

echo "Done!"
rm -rf /root/keys.zip 
