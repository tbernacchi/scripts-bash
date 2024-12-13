#!/bin/sh

FILE="/usr/local/bin/pipe-pix/imgs.txt"

REPO_JD="567129696518.dkr.ecr.sa-east-1.amazonaws.com"
REPO_ACESSO="788631756830.dkr.ecr.us-east-1.amazonaws.com"

JSON_SLACK=`mktemp --suffix=-JDPIPE-slack-GROUP-$GROUP`

SLACK_PIPEJD_API="https://hooks.slack.com/services/TP15N9HGT/B01ED8T9M08/M00024324343jh334n343k4"

LOCK="/tmp/sync-jd-repo.lck"

fn_check_lock()
{
  if [ -e $LOCK   ]
  then
    rm -f `find $LOCK -cmin +240`
    echo "Arquivo de lock $LOCK encontrado, saindo..."
    exit 0
  else
    echo $$ > $LOCK
		# garantido o docker
		systemctl enable docker
		systemctl start docker
		fn_get_info_acesso
		fn_gc
  fi
}

fn_send_slack()
{
cat > $JSON_SLACK <<END
{
	"channel": "#pipe-jd",
  "username": "webhookbot",
  "text": "Nova imagem: $URI_DEST",
  "icon_emoji": ":biohazard_sign:"
}
END
	curl -X POST -H 'Content-Type: data-urlencode' -d@$JSON_SLACK $SLACK_PIPEJD_API
}

fn_get_info_acesso()
{
  # logamos no nosso repo
  aws --profile pix-svc-rundeck ecr get-login-password | docker login --username AWS --password-stdin $REPO_ACESSO

  # Separamos a lista de repos para verificar se exite na nossa conta
  for repo in `cat $FILE | sed "s/$REPO_JD\/jdpi\///g" | cut -f1 -d":"` 
  do
    aws --profile pix-svc-rundeck ecr describe-repositories --query "repositories[].repositoryName" --output text | grep $repo > /dev/null

    if [ `echo $?` != 0 ]
    then
      # repo nao existe, temos que criar
      aws --profile pix-svc-rundeck ecr get-login-password
      aws --profile pix-svc-rundeck ecr create-repository --image-tag-mutability IMMUTABLE --repository-name $repo
    fi
      # agora fazendo o pull na origem e o push no destino
      fn_sync_tag

  done

}

fn_sync_tag()
{
  for URI_SRC in `cat $FILE | grep $repo`
  do
    # para cada iteracao logamos na origem
    aws --profile jd-pipe-pix ecr get-login-password | docker login --username AWS --password-stdin $REPO_JD
    docker pull $URI_SRC

    # temos que trocar a tag para o nosso padrao
    URI_DEST=`echo $URI_SRC | sed "s/$REPO_JD\/jdpi/$REPO_ACESSO/g"`
    docker tag $URI_SRC $URI_DEST

    # depois de obter a origem, na iteracao temos que logar no destino
    aws --profile pix-svc-rundeck ecr get-login-password | docker login --username AWS --password-stdin $REPO_ACESSO

    # agora enviamos para o nosso repo
    docker push $URI_DEST

    # clean
    docker image prune -a -f

    # notificamos via slack
    fn_send_slack
  done
}

fn_gc()
{
  rm -rf $LOCK $JSON_SLACK
  systemctl stop docker
}

# main
fn_check_lock
