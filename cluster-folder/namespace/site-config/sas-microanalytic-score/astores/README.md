---
category: SAS Micro Analytic Service
tocprty: 1
---

# Configure SAS Micro Analytic Service to Support Analytic Stores
                  
## Overview

Configuring analytic store (ASTORE) directories is required in order to publish analytic store models from SAS Intelligent Decisioning, SAS Model Manager, and Model Studio to a SAS Micro Analytic Service publishing destination.

Configuring SAS Micro Analytic Service to use ASTORE files inside the container requires persistent storage from the cloud provider. A PersistentVolumeClaim (PVC) is defined to state the storage requirements from cloud providers. The storage provided by cloud is mapped to predefined paths across services collaborating to handle ASTORE files.

**Note:** This overlay can be applied during the initial deployment of the SAS Viya platform or after the deployment of the SAS Viya platform.

**Note:** If you are configuring this overlay in a multi-tenant environment, perform the steps in the [Multi-Tenant Configuration](#multi-tenant-configuration) section.


## Prerequisites

Storage for the ASTORE files must support ReadWriteMany access permissions.

**Note:** The STORAGE-CLASS-NAME from the provider is used to determine the STORAGE-CAPACITY that is required for your ASTORE files. The required storage capacity depends on the size and number of ASTORE files.

## Installation

1. Copy the files in `$deploy/sas-bases/examples/sas-microanalytic-score/astores` to the `$deploy/site-config/sas-microanalytic-score/astores` directory. Create the destination directory, if it does not already exist.

   **Note:** If the destination directory already exists, [verify that the overlays](#verify-overlays-for-the-persistent-volumes) have been applied. 
   If the output contains the `/models/astores/viya` and `/models/resources/viya` mount directory paths, you do not need to take any further actions, unless you want to change the overlay parameters for the mounted directories.
   
2. The resources.yaml file in `$deploy/site-config/sas-microanalytic-score/astores` contains the parameters of the storage that is required in the PeristentVolumeClaim. For more information about PersistentVolumeClaims, see [Additional Resources](#additional-resources).

   * Replace {{ STORAGE-CAPACITY }} with the amount of storage required.
   * Replace {{ STORAGE-CLASS-NAME }} with the appropriate storage class from the cloud provider that supports ReadWriteMany access mode.

3. Make the following changes to the base kustomization.yaml file in the $deploy directory.

   * Add site-config/sas-microanalytic-score/astores/resources.yaml to the resources block.
   * Add sas-bases/overlays/sas-microanalytic-score/astores/astores-transformer.yaml to the transformers block.
 
   Here is an example:

   ```yaml
   resources:
   - site-config/sas-microanalytic-score/astores/resources.yaml

   transformers:
   - sas-bases/overlays/sas-microanalytic-score/astores/astores-transformer.yaml
   ```

4. Complete one of the following deployment steps to apply the new settings.

   * If you are applying the overlay during the initial deployment of the SAS Viya platform, complete all the tasks in the README files that you want to use, and then see [Deploy the Software](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=p127f6y30iimr6n17x2xe9vlt54q.htm) in _SAS Viya Platform: Deployment Guide_ for more information.
   * If you are applying the overlay after the initial deployment of the SAS Viya platform, see [Modify Existing Customizations in a Deployment](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=n1f2q6pp0gjheqn1jl204vptrubs.htm) in _SAS Viya Platform: Deployment Guide_ for information about how to redeploy the software.
   
## Verify Overlays for the Persistent Volumes

1. Run the following command to verify whether the overlays have been applied:

   ```sh
   kubectl describe pod  <sas-microanalyticscore-pod-name> -n <name-of-namespace>
   ```

2. Verify that the output contains the following mount directory paths:

   ```yaml
   Mounts:
     /models/astores/viya from astores-volume (rw,path="models")
     /models/resources/viya from astores-volume (rw,path="resources")
   ```
## Multi-Tenant Configuration

In a multi-tenant environment, the ASTORE and resource files are stored in subdirectories that are specific to each tenant and they are secured.

1. During the tenant onboarding process, a subdirectory is created for each tenant on the astores and resources PVC. The subdirectory name is the same as the tenant name. 
   Here is an example: If the tenant is named CompanyA, then a directory named CompanyA is created on each PVC.
   
   The owner of the tenant directory is then set to `sas (user 1001)` and the permissions on the directory are set to Read, Write, and Execute for user and group, and Execute for other.

2. After a tenant is onboarded, secure the directories for each tenant:

   1) Create a group specific to the tenant that contains users for the tenant that might need access to the directory for administrative purposes. Also, add the `sas` user to each group.
   2) Set the owner group of the tenant directory to the tenant-specific group that was created in the previous step.
   
## Additional Resources

* [SAS Viya Platform: Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm)
* [Persistent Volume Claims on Kubernetes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
* [Accessing Analytic Store Model Files](http://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calmodels&docsetTarget=n10916nn7yro46n119nev9sb912c.htm) in _SAS Viya Platform: Models Administration_
* [Configuring Analytic Store and Python Model Directories](http://documentation.sas.com/?cdcId=mascdc&cdcVersion=default&docsetId=masag&docsetTarget=n0er040gsczf7bn1mndiw7znffad.htm) in _SAS Micro Analytic Service: Programming and Administration Guide_