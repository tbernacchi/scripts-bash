#!/bin/sh

REGION=sa-east-1
aws ec2 describe-images --owners 028473989100 \
--query 'sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]' \
--filters "Name=name,Values=*Ubuntu*" --region $REGION --output table
