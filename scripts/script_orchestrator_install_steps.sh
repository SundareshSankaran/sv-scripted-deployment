#!/usr/bin/env bash

# set -e

# Parameters:
# 1 = deploy folder
# 2 = cluster name
# 3 = namespace
# 4 = Logs
# 5 = desired name for service principal


./move_logs.sh $4
./setup_iac_tooling_azure.sh $1 > $4/setup_`date +%Y%m%d%H%M`.log
./create_terraform_plan_azure.sh $1 $5 > $4/create_plan_`date +%Y%m%d%H%M`.log
./apply_terraform_plan_azure.sh $1 $5 > $4/apply_plan_`date +%Y%m%d%H%M`.log
./prepare_deployment_tool.sh $1 > $4/prep_dep_`date +%Y%m%d%H%M`.log
./deploy_baseline.sh $1 $2 $3 > $4/deploy_baseline_`date +%Y%m%d%H%M`.log
./deploy_viya.sh $1 $2 $3 > $4/deploy_viya_`date +%Y%m%d%H%M`.log
./obtain_ingress_service_ip.sh $1 $2 $4 > $4/ingress_service_ip_`date +%Y%m%d%H%M`.log

