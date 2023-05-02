#!/usr/bin/env bash

set -e

# Parameters:
# 1 = deploy folder
# 2 = cluster name
# 3 = logs

kubectl --kubeconfig=${1}/${2}-kubeconfig.conf -n ingress-nginx get svc ingress-nginx-controller -o=custom-columns=EXTERNAL-IP:.status.loadBalancer.ingress > ${3}/EXTERNAL_IP.md
