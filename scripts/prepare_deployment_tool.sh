#!/usr/bin/env bash

# Parameters:
# 1 = deploy folder

git clone https://github.com/sassoftware/viya4-deployment

docker build viya4-deployment/ -t viya4-deployment --platform linux/x86_64

cp viya4-deployment/examples/ansible-vars.yaml $1/ansible-vars-template.yaml

echo "Now, edit the ansible-vars-template.yaml file"

rm -rf viya4-deployment

echo "Viya4-deployment removed."

