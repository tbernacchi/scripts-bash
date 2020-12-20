#!/bin/bash
echo "Terminating all instances..."
REGIONS=($(aws ec2 describe-regions | jq -r '.Regions[] | .RegionName' | sort))

for i in `echo "${REGIONS[@]}"`;do
	INSTANCES_ID=($(aws ec2 describe-instances --region "${i}" | jq -r '.Reservations[].Instances[].InstanceId'))
		for instance in `echo "${INSTANCES_ID[@]}"`;do 
			#aws ec2 modify-instance-attribute --region "${i}" --instance-id "${instance}" --disable-api-termination "{\"Value\": false}"  2>&1 > /dev/null
			aws ec2 terminate-instances --region "${i}" --instance-id "${instance}" 2>&1 > /dev/null
		done
done

echo "Done!"
