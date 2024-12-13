#!/bin/sh

DIR="/rundeck-logs-json/"

for FILES in `find $DIR -type f -ctime +10`
do
  rm -f $FILES
done
