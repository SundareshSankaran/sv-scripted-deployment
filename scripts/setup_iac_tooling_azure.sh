#!/usr/bin/env bash

# Preferably run this at the top level of your installation directory.

# Parameters
# 1 - name of cluster directory

git clone https://github.com/sassoftware/viya4-iac-azure.git
cd viya4-iac-azure
GITTAG=$(git describe --tags)
export GITTAG
cd ..

echo "You are using version $GITTAG of viya4-iac-azure" >> $1/CURRENT_VERSION.md
CURRENT_AKS_WITHIN_SUPPORT=$(az aks get-versions --location eastus --query 'orchestrators[*].orchestratorVersion' | jq --arg version 1.24 -c '.[] | select(contains($version))' | sort -V | tail -1 | tr -d '\\\"')
export CURRENT_AKS_WITHIN_SUPPORT

echo "$CURRENT_AKS_WITHIN_SUPPORT" > $1/AKS_VERSION_TODAY.md

docker build viya4-iac-azure/ -t viya4-iac-azure --platform linux/x86_64

mkdir -p $1

chmod 0777 $1

if [ -f $1/terraform.tfvars ]; then
   cp $1/terraform.tfvars $1/terraform.tfvars.old
fi

cp viya4-iac-azure/examples/sample-input-ha.tfvars $1/terraform-example.tfvars

chmod 0777 $1/terraform.tfvars

echo "Now, edit the terraform-example.tfvars file in folder $1"

rm -rf viya4-iac-azure

echo "Viya4-iac-azure build directory removed."