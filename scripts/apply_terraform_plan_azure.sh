#!/usr/bin/env bash

# Parameters
# 1 - Cluster folder (deploy folder)
# 2 - Service Principal Name
# Note: The credentials file is assumed in $HOME as .azure_creds_service-principal-name.env

rm -r $1/*.tfstate
rm -r $1/*.tfstate.backup


docker run --rm --platform linux/x86_64 --group-add root \
  --user "$(id -u):$(id -g)" \
  --env-file $HOME/.azure_creds_$2.env \
  --volume $HOME/.ssh:/.ssh \
  --volume $1:/workspace \
  viya4-iac-azure \
  apply -auto-approve \
        -var-file /workspace/terraform.tfvars \
        -state /workspace/terraform.tfstate \
        -refresh=true

CLUSTER_NAME=$(cat $1/terraform.tfstate| jq .outputs.cluster_name.value|sed 's/\"//g')
echo "The cluster name is $CLUSTER_NAME"

