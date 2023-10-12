#!/bin/bash
# Note, this assumes saml2aws is configured to manage a profile called "scc". https://github.com/Versent/saml2aws
# See the steps for "Access via CLI" in: https://confluence.suse.com/display/SSTE/File+uploads+to+SUSE+Support
# Downloads logs from case number SF from S3 bucket customer-uploads-suse-com to working DIR.
# Update autor: Tadeu Bernacchi
# Email: tadeu.bernacchi@suse.com| 
# Date:  02/03/2022
CASE_NUMBER="$1"

function scc-logs {

BASE_DIR="${HOME}/rancher/tickets"
#BASE_DIR="${HOME}/Downloads"
WORKING_DIR="${BASE_DIR}/${CASE_NUMBER}"

if [ -z "${CASE_NUMBER}" ] 
  then
    echo "No argument supplied"
    return 1
fi

if [ ! -d "$WORKING_DIR" ]
  then
    mkdir -p "$WORKING_DIR"
    cd "$WORKING_DIR"
    scc-login
    aws --profile scc s3 sync s3://customer-uploads-suse-com/$CASE_NUMBER/ $WORKING_DIR/
  else
    echo "Dir already exists, switching to it"
    cd "$WORKING_DIR"
    #if read -q  "REPLY?Do you want to sync files from s3 again? (y/n) "
      #then
        #echo; 
    scc-login
	  aws --profile scc s3 sync s3://customer-uploads-suse-com/$CASE_NUMBER/ $WORKING_DIR/
    #fi
fi

}

function scc-login {

echo "Checking for credentials"
if ! aws --profile scc sts get-caller-identity >> /dev/null
  then
    echo "Credentials expired, logging in"
    saml2aws login
fi

}
scc-logs 
scc-login 
