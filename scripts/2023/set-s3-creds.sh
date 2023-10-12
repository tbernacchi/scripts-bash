#!/bin/bash

export PATH=./:$PATH

# Determine OS and architecture
case $(uname -s) in
	Linux*)     os="linux" ;;
	Darwin*)    os="darwin" ;;
	*)          echo "Unsupported OS detected"; exit;;
esac
case $(uname -m) in
	x86_64) arch="amd64" ;;
	arm64)  arch="arm64" ;;
	arm)    dpkg --print-architecture | grep -q "arm64" && arch="arm64" || arch="arm" ;;
	*)      echo "Unsupported architecture detected"; exit;;
esac

# Check yq
if ! which yq >/dev/null; then
	echo "Could not find yq in path, you will be prompted to install"
	while true; do
		read -p "Install yq v4.2.0? (y/n) " yn
		case $yn in
			[Yy]* ) echo "Installing yq"; curl "https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_${os}_${arch}" -L -o "./yq" && chmod +x ./yq; break;;
			[Nn]* ) echo "yq is required for this script" && exit;;
			* ) echo "Please answer yes or no.";;
	esac
	done
fi

# Check kubectl
prompt=false

if ! which kubectl >/dev/null; then
	echo "Could not find kubectl in path, you will be prompted to install"
	prompt=true
else
	minor=$(kubectl version --short | grep "Client Version:" | cut -d ' ' -f 3 | cut -d '.' -f 2)
	if [ $minor -lt 24 ]; then
		echo "Incompatible kubectl version detected (require 1.24+), you will be prompted to install locally (cwd)"
		prompt=true 
	fi
fi

latest=$(curl -L -s https://dl.k8s.io/release/stable.txt)
while $prompt; do
	read -p "Install kubectl $latest? (y/n) " yn
	case $yn in
		[Yy]* ) echo "Installing kubectl $latest"; curl -LO "https://dl.k8s.io/release/${latest}/bin/${os}/${arch}/kubectl" && chmod +x ./kubectl; break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
esac
done

# Read inputs
echo "Enter cluster ID (c-xxxxx):"
read CLUSTER_ID

echo "Enter Bucket Name:"
read BUCKET_NAME
echo "Enter Endpoint: (default: s3.amazonaws.com)"
read ENDPOINT
if [ -z "$ENDPOINT" ]; then
	ENDPOINT="s3.amazonaws.com"
fi
echo "Enter Folder:"
read FOLDER
echo "Enter Region (default: us-east-1)":
read REGION
if [ -z "$REGION" ]; then
	REGION="us-east-1"
fi
echo "Enter Access Key:"
read ACCESS_KEY
echo "Enter Secret Key (WILL BE VISIBLE ON THE SCREEN):"
read SECRET_KEY

# Extract cluster info
echo "Extracting cluster info"
yaml=$(kubectl get -n fleet-default cluster.management.cattle.io "$CLUSTER_ID" -o yaml)
CLUSTER_UID=$(echo -n "$yaml" | yq e '.metadata.uid' -)

# Prepare secret
echo "Preparing secret"
TMPL="apiVersion: v1
data:
  credential: %s
kind: Secret
metadata:
  generateName: cluster-s3backup-
  namespace: cattle-global-data
  ownerReferences:
  - apiVersion: management.cattle.io/v3
    kind: Cluster
    name: %s
    uid: %s
type: Opaque
"
printf -v OUT "$TMPL" "$(echo -n "$SECRET_KEY" | base64)" "$CLUSTER_ID" "$CLUSTER_UID"

# Create secret
echo "Creating secret"
SECRET_NAME=$(echo "$(echo "$OUT" | kubectl create -f -)" | cut -d '/' -f 2 | cut -d ' ' -f 1)

# Patch management cluster
echo "Patching management cluster"
PATCH="spec:
  rancherKubernetesEngineConfig:
    services:
      etcd:
        backupConfig:
          s3BackupConfig:
            accessKey: $ACCESS_KEY
            bucketName: $BUCKET_NAME
            endpoint: $ENDPOINT
            folder: $FOLDER
            region: $REGION
status:
  s3CredentialSecret: %s"
printf "$PATCH" "$SECRET_NAME" > patch.yaml
kubectl patch -n fleet-default cluster.management.cattle.io "$CLUSTER_ID" --patch-file patch.yaml --type merge

echo "s3 backups successfully enabled for cluster $CLUSTER_ID"
CLEAN_EXISTING=false
while true; do
	read -p "Clean up existing orphaned secrets? (y/n) " yn
	case $yn in
		[Yy]* ) CLEAN_EXISTING=true; break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
esac
done

if [ $CLEAN_EXISTING ]; then
	echo "Cleaning up orphaned secrets";
	secrets=$(kubectl get secrets -n cattle-global-data | grep "cluster-s3backup-" | cut -d ' ' -f 1)
	COUNT=0
	for secret in $secrets; do
		output=$(./kubectl get secret -n cattle-global-data $secret -o yaml);
		if ! echo $output | grep -q "ownerReferences"; then
			kubectl delete secret -n cattle-global-data $secret
			COUNT=$((COUNT + 1))
		fi
	done
	echo "Cleaned up $COUNT secrets"
fi
