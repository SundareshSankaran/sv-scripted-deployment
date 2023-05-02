#!/usr/bin/env bash

# set -e

# Parameters:
# 1 = deploy folder
# 2 = cluster name
# 3 = namespace
# 4 = Logs
# 5 = Name of service principal

./setup_iac_tooling_azure.sh $1 > $4/setup_`date +%Y%m%d%H%M`.log
./prepare_deployment_tool.sh $1 > $4/prep_dep_`date +%Y%m%d%H%M`.log
./uninstall_viya.sh $1 $2 $3 > $4/uninstall_viya_`date +%Y%m%d%H%M`.log
./uninstall_baseline.sh $1 $2 $3 > $4/uninstall_baseline_`date +%Y%m%d%H%M`.log
./destroy_terraform_plan_azure.sh $1 $5 > $4/destroy_plan_`date +%Y%m%d%H%M`.log


