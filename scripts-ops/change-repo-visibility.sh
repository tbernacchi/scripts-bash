#!/bin/bash

# List of repositories to be updated to public
repos=(
    "tbernacchi/take-home-assignment-main"
    "tbernacchi/bitcoin-investment-tracker"
    "tbernacchi/home-lab"
    "tbernacchi/rollouts-demo"
    "tbernacchi/gh-actions-terraform"
    "tbernacchi/argo-events"
    "tbernacchi/wiki-engine"
    "tbernacchi/scripts-bash"
    "tbernacchi/k8s-gateway-api"
    "tbernacchi/microservices-bookstore-argo-workflow"
    "tbernacchi/aws-upload-notifier"
    "tbernacchi/prometheus-dump-python-s3"
    "tbernacchi/terraform-gcp-gke-postgresql"
    "tbernacchi/fibonacci"
    "tbernacchi/kubernetes-containerd"
    "tbernacchi/mongodump-python"
)

# Repositories that will not be changed
skip_repos=(
    "tbernacchi/dre-3-test"
    "tbernacchi/dre-airflow"
    "tbernacchi/rollouts-demo-ambrosia"
    "tbernacchi/bitcoin-fetcher-notification"
    "tbernacchi/home-lab-old"
)

# Function to check if the repository should be skipped
should_skip() {
    local repo=$1
    for skip in "${skip_repos[@]}"; do
        if [[ "$repo" == "$skip" ]]; then
            return 0  # Repository found in the skip list
        fi
    done
    return 1  # Not found, can be processed
}

# Iterate over the repositories
for repo in "${repos[@]}"; do
    if should_skip "$repo"; then
        echo "Skipping $repo..."
    else
        echo "Changing visibility of $repo to public..."
        gh repo edit "$repo" --visibility public --accept-visibility-change-consequences
    fi
done

echo "Visibility change complete."

