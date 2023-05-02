#!/usr/bin/env bash

# Parameters
# 1 - Cluster folder (deploy folder)
# 2 - Cluster name


kubectl --kubeconfig=${1}/${2}-kubeconfig.conf  patch storageclass default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl --kubeconfig=${1}/${2}-kubeconfig.conf  patch storageclass sas -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

