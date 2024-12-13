#!/bin/bash
# Create user/Access_Key on Aws and send the credentials to PwPush and notify the user at Slack! 
##### https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens
##### Change the ambrosiaglobal.slack to your slack workspace.
##### Check the URL to login at AWS (signin.aws.amazon.com/console) line 84.
SLACK_TOKEN="xoxp-xxxxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

USERNAME=${1}
shift

if [ -z ${USERNAME} ]; then
  echo "ERROR: Usage: ${0} <username>"
  exit 1
fi

# Check if the user exists
LIST_USER=($(aws iam list-users | jq -r ".Users[].UserName" | grep ${USERNAME}))

if [ "${LIST_USER}" == "${USERNAME}" ]; then
	echo "User found => ${USERNAME}"
	echo "Checking if there are any access keys for this user..."

existing_access_keys=($(aws iam list-access-keys --user-name "${USERNAME}" | jq -r '.AccessKeyMetadata[].AccessKeyId'))

    if [ ${#existing_access_keys[@]} -gt 0 ]; then
    	echo "It was found ${#existing_access_keys[@]} Access Key for this user, removing it..."
      		for accesskey in ${existing_access_keys[@]}; do
        		aws iam delete-access-key --user-name "${USERNAME}" --access-key-id "${accesskey}"
      		done
    fi  
else
	echo "User not found!"
	echo "Creating User..."
	CREATE_USER=($(aws iam create-user --user-name "${USERNAME}"))
fi

echo "Creating Access Key for this user..."

ACCESS_KEY_OUTPUT=($(aws iam create-access-key --user-name "${USERNAME}" | jq -r '.AccessKey | "\(.AccessKeyId) \(.SecretAccessKey)"'))
ACCESSKEYID="${ACCESS_KEY_OUTPUT[0]}"
SECRETACCESSKEY="${ACCESS_KEY_OUTPUT[1]}"

echo "Generating passwords URL's from PWPUSH..."

#Send to pwpush
URL_TOKEN_ACCESSKEY=$(curl -X POST https://pwpush.com/p.json \
  --stderr /dev/null \
  --data-urlencode "password[payload]=${ACCESSKEYID}" \
  -d "password[expire_after_days]=1" \
  -d "password[expire_after_views]=8" | jq -r .url_token
)

URL_TOKEN_SECRETKEY=$(curl -X POST https://pwpush.com/p.json \
  --stderr /dev/null \
  --data-urlencode "password[payload]=${SECRETACCESSKEY}" \
  -d "password[expire_after_days]=1" \
 -d "password[expire_after_views]=8" | jq -r .url_token
)

#Pwpush URL
PWPUSH_URL_ACCESSKEY="https://pwpush.com/p/${URL_TOKEN_ACCESSKEY}"
PWPUSH_URL_SECRETKEY="https://pwpush.com/p/${URL_TOKEN_SECRETKEY}"

#Get User ID Slack
USER_ID_SLACK=$(curl \
    --stderr /dev/null \
    -d "token=${SLACK_TOKEN}" \
    https://ambrosiaglobal.slack.com/api/users.list \
    | jq -r '.members[] | select(.name == "'${USERNAME}'") | .id'
)

ID_MSG=$(curl \
    --stderr /dev/null \
    -d "token=${SLACK_TOKEN}" \
    https://ambrosiaglobal.slack.com/api/im.list \
    | jq -r '.ims[] | select(.user == "'${USER_ID_SLACK}'") | .id'
)

SLACK_MESSAGE="
Hello ${USERNAME},

Your accesses to AWS console were created.

Login: https://<your_organization>.signin.aws.amazon.com/console

AcessKey ID: ${PWPUSH_URL_ACCESSKEY}
SecretKey: ${PWPUSH_URL_SECRETKEY}

Don't forget to set your MFA::
https://docs.aws.amazon.com/pt_br/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html

See ya!
"

echo "Sending credentials to user..."

curl \
  -s \
  --stderr /dev/null \
  -d "token=${SLACK_TOKEN}" \
  -d "channel=${ID_MSG}" \
  -d "as_user=true" \
  -d "unfurl_links=true" \
  -d "text=${SLACK_MESSAGE}" \
   https://ambrosiaglobal.slack.com/api/chat.postMessage > /dev/null

echo "Done!"