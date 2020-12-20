#!/bin/bash
echo "Removing all volumes..."
REGIONS=($(aws ec2 describe-regions | jq -r '.Regions[] | .RegionName' | sort))

for i in `echo "${REGIONS[@]}"`;do
	VOLUMES_ID=($(aws ec2 describe-volumes --region "${i}" | jq -r '.Volumes[] | .VolumeId'))
	for volume in `echo "${VOLUMES_ID[@]}"`;do 
		aws ec2 detach-volume --region "${i}" --volume-id "${volume}" 
		aws ec2 delete-volume --region "${i}" --volume-id "${volume}" 
	done
done  
echo "Done!"