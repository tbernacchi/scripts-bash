#!/bin/bash

FILEDB="/tmp/rundeck.db"

curl -v -H "Accept: application/json" -X GET "http://rundeck.tabajara.local:4440/api/20/project/tabajaraBatch/executions?authtoken=ixWUqfl9WwHxQ1inFEHbRDVXMF4nt4R2" | python -m json.tool > $FILEDB

for JOB in `cat $FILEDB | jq . | grep -w name | awk '{ print $2 }' | sed -e 's/"//g' -e 's/,//g'`
	do
		echo $JOB
		DTEND=`cat $FILEDB | jq . | grep -w $JOB -B16 | head -n1`
		DTSTART=`cat $FILEDB | jq . | grep -w $JOB -B12 | head -n1`
	done

