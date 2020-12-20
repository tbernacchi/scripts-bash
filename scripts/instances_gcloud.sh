#!/bin/sh
## Create three instances on Google Cloud with names - centos6/centos7/debian9
VAR1="centos6 centos7 debian9"
VAR2="centos-6-v20180104 \
centos-7-v20180104 \
debian-9-stretch-v20180105"

fun()
{
    set $VAR2
    for i in $VAR1; do
	gcloud compute instances create "$i" --machine-type=n1-standard-1 --zone=southamerica-east1-a --image-project="$1"
        shift
    done
}

fun
