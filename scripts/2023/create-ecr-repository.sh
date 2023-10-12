#!/bin/bash
function check_create_repo() {

repos=`aws ecr describe-repositories | jq '.repositories[].repositoryName' | sed 's/"//g'`
#echo $repos

check_repo=`aws ecr create-repository --repository-name $1 2>> /dev/null`
status="$?"

for repo in `echo $repos`;do
	if [[ $repo == $1 && $status == 254 ]];then
		echo "Repo exist: Uploading $1..."
    		#Faz o upload com comando ou funcao.
	else
		    #echo "Repo does not exist: Creating and uploading $1..."
    		aws ecr create-repository --repository-name $1 2>> /dev/null

	fi
done
check_create_repo
