# Sandbox Environment : Azure template

Use this branch as a guide to create sandbox Viya 4 environments on Azure.


Current results : <mark>[here](/LOG.md#tldr)</mark>

## Details


## Folder Structure


### Scripts
This folder will contain a collection of scripts which will define the deployment and configuration path. These scripts can also be used for guidance & future handoff (with the caveat that installation resources may  continuously change).


<mark>

**Note that these scripts are for illustrative / guidance purposes only.**  Repositories used by these scripts may be subject to their own license of usage, please refer the same carefully.   The main scripts are shown below, but the scripts folder contains all the others.

</mark>

Current contents:
| Sl No  | Name          | Description     |
|--------|---------------|-----------------|
| 1|[Installer Script Example](./scripts/script_orchestrator_install_steps.sh)  | You choose what to do here, but consider this as a script which can carry out an end to end deployment from scratch by calling relevant other scripts.  Some elements, such as making a DNS entry etc. are manual.|
| 2|[Uninstaller Script Example](./scripts/script_orchestrator_install_steps.sh)  | You choose what to do here.  Use this to script an uninstall / destroy process.  It's recommended to uninstall some components before others - viya, then baseline, then destroy cluster (for obvious reasons).  You may like to uninstall one component, check and then proceed to the other.|



### Cluster Folder

Once a Kubernetes cluster is created, [this folder](/cluster-folder/) will house what is termed as the [$deploy](/cluster-folder/) directory.  The cluster's state (a Terraform tfstate file) will sit at the top level of this folder. Every namespace which deploys Viya will be contained within a directory of the same name.  Rename the cluster folder after you have created a new branch / fork.

#### Namespace Folder
Usually called viya.  Rename the [namespace folder](/cluster-folder/namespace/) after you have created a new branch / fork.

**Also note that the ansible vars for this namespace makes an assumption that the FQDN will be {{NAMESPACE}}.{{CLUSTER_NAME}}.unx.sas.com (referring to a specific corp domain).  Please do change the same.**

Ansible-vars inside **CLUSTER_FOLDER** is what you may like to change.  The script basically takes the ansible vars from the cluster folder, tacks on a NAMESPACE tag and then moves it to the namespace folder specified.  This was done to support the automation for this repo, but may not make sense as a pattern in other situations.  Either way, if you choose to use a different ansible-vars file, make sure that scripts like [deploy-viya](./scripts/deploy_viya.sh), [deploy_baseline](./scripts/deploy_baseline.sh) etc. are modified accordingly.



##### IMPORTANT - SITE-CONFIG folder within NAMESPACE folder
The files provided in the [site-config](./cluster-folder/namespace/site-config/) folder are only examples of the typical customisations and overlays you may expect to inject into your deployment.  Please note that due to the CI/CD nature of SAS Viya, **manifests and customizations may change over releases**.  Always check the sas-bases/examples folder for the most updated customizations before plugging them into site-config.



Otherwise, a common usage pattern is that you decide on the overlays and customizations you require, and save them within folders in site-config.  The viya4-deployment Docker container, called within scripts in this repository will pick them up and add to the final kustomization.yaml.




### Logs
The [log](/LOG.md) contains a recap of activities carried out throughout this project.  The [Logs folder](/logs/) will contain detailed logs.


### Subscription Details
This [file](/subscription/DETAILS.md) and its parent [folder](/subscription/) will host any installation related details about the AWS subscription.



### Final Cost update (for indicative purposes, internal)

