#!/bin/bash
REGISTRY="$1"

function check_args () {

  if [ -z $REGISTRY ];then
  	echo "[ERROR]: You should pass your registry"
        exit 1
  else
        echo "Registry: $REGISTRY"
  fi

}

function check_credentials () {

echo "Checking for credentials..."
  aws ecr get-login-password --region sa-east-1 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
	echo "Unable to locate credentials. You can configure credentials by running "aws configure"."
        exit 1
  else
  	tag_push_images
	echo "Tagging images..."
	echo "Pushing images..."
	echo "Done!"
  fi

}

function tag_push_images () {

	IMAGES=`docker images | awk '{ print $1,$2 }'| egrep -iv 'repository|tag' | sed 's/ /:/g'`
	for img in `echo $IMAGES`;do
		TAGS=`echo $img | awk '{ print $1,$2 }'| egrep -iv "repository|tag" | sed 's/ /:/g' | awk -F/ '{ print $2 }' | sed 's/:/-/g' | sed 's/.$//'`
			for tag in `echo $TAGS`;do
				echo "docker image tag $img ${REGISTRY}:$tag" >> docker-images-tag.txt
				#docker image tag $img ${REGISTRY}:$tag" 2>&1 > /dev/null
				echo "docker push $REGISTRY:$tag" >> docker-images-push.txt
				#docker push $REGISTRY:$tag" 2>&1 > /dev/null
			done
	done
}
check_args
check_credentials
tag_push_images

#Fazer um teste de credentials/login com o 'docker push', se der ruim fazer o login com esse
aws ecr get-login-password --region sa-east-1 | docker login --username AWS --password-stdin 028473989100.dkr.ecr.sa-east-1.amazonaws.com
