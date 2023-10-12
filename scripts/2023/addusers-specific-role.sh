#!/bin/bash

access_key="YOUR_ACCESS_KEY"
secret_key="YOUR_SECRET_KEY"
cluster_id="YOUR_CLUSTER_ID"

users=$(curl --insecure -u "$access_key:$secret_key" -X GET "https://YOUR_RANCHER_URL/v3/users" | jq '.data[]')

user_ids=$(echo "$users" | jq -r '.id')

for user_id in $user_ids; do
  curl --insecure -u "$access_key:$secret_key" -X POST "https://YOUR_RANCHER_URL/v3/clusterroletemplatebindings" \
  -H 'Content-Type: application/json' \
  --data-raw '{"type":"clusterRoleTemplateBinding","clusterId":"'$cluster_id'","roleTemplateId":"cluster-member","userPrincipalId":"local://'$user_id'"}'
done
