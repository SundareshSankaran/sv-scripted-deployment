#!/usr/bin/env bash

# Parameters
# 1 - Cluster folder (deploy folder)
# 2 - Cluster name
# 3 - Namespace

CLUSTER_NAME=$2
NAMESPACE=$3
echo ${NAMESPACE}
chmod 0600 $1/${CLUSTER_NAME}-kubeconfig.conf
echo "## Cluster" > /tmp/file1.yaml
echo "NAMESPACE: ${NAMESPACE}" > /tmp/file2.yaml
mkdir -p $1/$NAMESPACE && cat /tmp/file1.yaml /tmp/file2.yaml $1/ansible-vars.yaml > $1/$NAMESPACE/ansible-vars.yaml

docker run --rm --platform linux/x86_64 \
  --group-add root \
  --user $(id -u):$(id -g) \
  --volume $1/..:/data \
  --volume $1/$NAMESPACE/ansible-vars.yaml:/config/config \
  --volume $1/${CLUSTER_NAME}-kubeconfig.conf:/config/kubeconfig \
  --volume $1/terraform.tfstate:/config/tfstate \
  --volume $HOME/.ssh/id_rsa:/config/jump_svr_private_key \
  viya4-deployment --tags "viya,uninstall"
  # viya4-deployment --tags "baseline,viya,cluster-logging,cluster-monitoring,viya-monitoring,uninstall"
  