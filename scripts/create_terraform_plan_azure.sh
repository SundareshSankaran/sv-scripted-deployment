#!/usr/bin/env bash

# Parameters
# 1 - Cluster folder (deploy folder)
# 2 - SP Name
# Note: The credentials file is assumed in $HOME as  .azure_creds_service-principal-name.env


docker run --rm --platform linux/x86_64 --group-add root \
  --user "$(id -u):$(id -g)" \
  --env-file $HOME/.azure_creds_$2.env \
  --volume $HOME/.ssh:/.ssh \
  --volume $1:/workspace \
  viya4-iac-azure \
  plan -var-file /workspace/terraform.tfvars \
       -state /workspace/terraform_planned.tfstate \
       -refresh=false