#!/usr/bin/env bash

# Parameters
# 1 - Cluster folder (deploy folder)
# 2 - Service Principal Name
# Note: The credentials file is assumed in $HOME as .azure_creds_your-sp-name.env

cp /$1/terraform.tfstate /$1/terraform_prevstate.tfstate

docker run --rm --platform linux/x86_64 --group-add root \
  --user "$(id -u):$(id -g)" \
  --env-file $HOME/.azure_creds_$2.env \
  --volume $HOME/.ssh:/.ssh \
  --volume $1:/workspace \
  viya4-iac-azure \
  destroy -auto-approve \
          -var-file /workspace/terraform.tfvars \
          -state /workspace/terraform.tfstate \
          -refresh=true

