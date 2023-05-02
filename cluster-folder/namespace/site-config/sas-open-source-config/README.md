---
category: openSourceConfiguration
tocprty: 1
---


# Configure Python and R Integration with the SAS Viya Platform

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation Workflow](#installing-and-configuring-python-and-r)
  1. [Installation of Python](#1-installation-of-python)
  2. [Installation of R](#2-installation-of-r-from-source)
  3. [Configure Python and R to Be Visible in the SAS Viya Platform](#3-configure-python-and-r-to-be-visible-in-the-sas-viya-platform)
  4. [Enable Lockdown Access Methods](#4-enable-lockdown-access-methods)
  5. [Configure the SAS Viya Platform to Connect to Python and R](#5-configure-the-sas-viya-platform-to-connect-to-python-and-r)
  6. [Configure External Access to CAS](#6-configure-external-access-to-cas)
  7. [Configure SAS Model Repository Service for Python and R Models](#7-configure-sas-model-repository-service-for-python-and-r-models)
  8. [Configure Git Integration in SAS Studio](#8-configure-git-integration-in-sas-studio)
- [Table of Deployment Assets and Resources](#table-of-capabilities-and-readmes)

## Overview

The SAS Viya platform can allow two-way communication between SAS (CAS and Compute engines) and open source environments (Python and R). This README describes the various post-installation steps required to install, configure, and deploy Python and R to enable integration in the SAS Viya platform.  

## Prerequisites

The SAS Viya platform provides YAML files that the Kustomize tool uses to configure Python. Before you use those files, you must perform the following tasks:

1. Configure persistent storage for your SAS Viya platform deployment such as an NFS server that can be mounted to a persistent volume. For more information, see [Storage Requirements](https://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=itopssr&docsetTarget=n0ampbltwqgkjkn1j3qogztsbbu0.htm#n0lu58nsmsvl4fn1nxtny4wvftov).
2. Configure the ASTORES persistent volume claim for the SAS Micro Analytic Service. For details, see the README file at `$deploy/sas-bases/examples/sas-microanalytic-score/astores/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_sas_micro_analytic_service_to_support_analytic_stores.htm` (for HTML format).
3. Provision and deploy the SAS Viya platform (2021.2.2 or later release).
4. To download and install Python and R, you must have access to the public internet. If your SAS Viya platform environment does not have public internet access, you must first download, install, and configure Python and R onto a separate internet-connected Linux environment. Then you should package up the directories (such as in a tarball) and copy them to the persistent storage available to your SAS Viya platform environment.

## Installing and Configuring Python and R

Each of the following numbered sections provides details about installation and configuration steps required to enable various open source integration points.

- To enable the use of Python and R code in SAS programs for data processing and model development in the SAS Viya platform, complete Steps 1-5.
- To enable external access to CAS from open-source programming languages such as Python and R (for example, using the SWAT package), complete Step 6.
- To enable the registration and publishing of open-source models using SAS Model Manager, complete Steps 1-5 (to enable open-source modeling) and Step 7.
- To enable the use of Git for version control of code (including SAS programs, Python scripts, R scripts) within the SAS Studio interface, complete Step 8.

### 1. Installation of Python

SAS provides the [SAS Configurator for Open Source](https://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=itopswn&docsetTarget=p19hj5ipftk86un1axa51rzr5mxv.htm#p081awrjl4tzdcn18dfto4qbz2n0) utility, which automates the download and installation of Python from source by creating and executing the `sas-pyconfig` job. For details, including the steps to configure one or more Python environments using the SAS Configurator for Open Source, see the README at `$deploy/sas-bases/examples/sas-pyconfig/README.md` (for Markdown format) or `$deploy/sas-bases/doc/sas_configurator_for_open_source_options.htm` (for HTML format). The example file `$deploy/sas-bases/examples/sas-pyconfig/change-configuration.yaml` contains default options that can be run as is or tailored to your environment, including which Python version to install, which collection of Python libraries to install, and whether to install multiple Python environments with different configurations (such as Python libraries or Python versions). Python is installed into a persistent volume that is mounted into the SAS Viya platform pods later (see [Step 3: Configure Python and R to Be Visible in the SAS Viya Platform](#3-configure-python-and-r-to-be-visible-in-the-sas-viya-platform)).

SAS recommends that you increase CPU and memory beyond the default values when using the SAS Configurator for Open Source to avoid out-of-memory errors during the installation of Python. See the Resource Management section of the README. Also, per [SAS Documentation: Required Updates by Component, #3](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=k8sag&docsetTarget=p0cc5i51v7t370n1q6a1n8n4bcsy.htm), you must delete the `sas-pyconfig` job after successful completion of the Python installation and before deploying a manual update. Otherwise, you will see an error similar to the following:

```sh
Job.batch "sas-pyconfig" is invalid: spec.template: Invalid value: ... field is immutable". 
```

You might also want to turn off the `sas-pyconfig` job by setting the `global.enabled` value to `false` in `$deploy/site-config/sas-pyconfig/change-configuration.yaml` file prior to executing future manual deployments, to prevent a restart of the `sas-pyconfig` job.

Note that the SAS Configurator for Open Source requires an internet connection. If your SAS Viya platform environment does not have access to the public internet, you will need to download, install, and configure Python on an internet-accessible device and transfer those files to your deployment environment.

### 2. Installation of R from Source

Install R from source in a persistent volume that will be mounted to the SAS Viya platform pods during [Step 3: Configure Python and R to be Visible in the SAS Viya Platform](#3-configure-python-and-r-to-be-visible-in-the-sas-viya-platform). After installing R, you should also download and install all desired R packages (for example, by starting an R session and executing the `install.packages(my-desired-package)` command). Two notes of caution:

1. Any shared library dependencies should be copied into the R directory that will be mounted to the SAS Viya platform pods. For example, required shared libraries can be copied from `/lib/[your-linux-distribution]` into the `/your-R-parent-directory/lib/R/lib` within the PVC directory where you install R (`/your-R-parent-directory`).
2. During installation of R, some hardcoded paths are pre-configured in the R and Rscript files to point to the installation directory. These hardcoded paths should match the mountPath that you plan to make available in the SAS Viya platform pods. If you configure a mountPath that differs from the installation location, there are at least two approaches available to you:
   - Modify these values in the `R` and `Rscript` files.
   - First install R into a temporary directory that matches the mountPath directory (such as `/r-mount`). You can specify the directory during the configuration of your R installation by setting the `--prefix=/{{ your-mountPath }}` option (where you replace `{{ your-mountPath }}` with the desired mountPath in your pods) when running `./configure`. Install all R packages within that `/r-mount` directory, and copy all shared libraries into the subdirectory `/r-mount/lib/R/lib`). Finally, copy or move the entire contents of `{{ your-mountPath }}` into your PVC directory of choice.

If your SAS Viya platform environment does not have access to the public internet, you will need to download, install, and configure R on an internet-accessible device and transfer those files to your deployment environment.

### 3. Configure Python and R to Be Visible in the SAS Viya Platform

Add NFS mounts for Python and R directories. Now that Python and R are installed on your persistent storage, you need to mount those directories so that they are available to the SAS Viya platform pods. Do this by copying transformers for Python and R from the `$deploy/sas-bases/examples/sas-open-source-config/python` and `$deploy/sas-bases/examples/sas-open-source-config/r` directories into your `$deploy/site-config/sas-open-source-config` Python and R directories. For details, refer to the following two READMEs:

- For Python, see the README at `$deploy/sas-bases/examples/sas-open-source-config/python/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_python_for_sas_viya_using_a_kubernetes_persistent_volume.htm` (for HTML format).
- For R, see the README at `$deploy/sas-bases/examples/sas-open-source-config/r/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_r_for_sas_viya.htm` (for HTML format).

This step makes the installed software visible to the SAS Viya platform pods. You must [enable lockdown access methods](#4-enable-lockdown-access-methods) (for Python) and [configure the SAS Viya platform to connect to your open-source packages](#5-configure-the-sas-viya-platform-to-connect-to-python-and-r) (both Python and R) to enable users to connect to R or Python from within a SAS Viya platform GUI.

### 4. Enable Lockdown Access Methods

This step opens up communication between Python or R, and the SAS Viya platform. You will need to enable `python` and `python_embed` methods for most, if not all, Python integration points; the `socket` method is also required to enable PROC Python and the Python Code Editor. For details, see `$deploy/sas-bases/examples/sas-programming-environment/lockdown/README.md`.

### 5. Configure the SAS Viya Platform to Connect to Python and R

These steps tell the SAS Viya platform how to connect to your Python and R binaries that you installed in the mounted directories. For details, see:

- For Python, see the README at `$deploy/sas-bases/examples/sas-open-source-config/python/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_python_for_sas_viya_using_a_kubernetes_persistent_volume.htm` (for HTML format).
- For R, see the README at `$deploy/sas-bases/examples/sas-open-source-config/r/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_r_for_sas_viya.htm` (for HTML format).

Following the steps in these two READMEs, you will update the Python- and R-specific `kustomization.yaml` files (in their respective folders within `$deploy/site-config/sas-open-source-config`) to replace the `{{ }}` placeholders with your installation's details (for example, `RHOME` path pointing to the parent directory where R is mounted). These `kustomization` files create environment variables that are made available in the SAS Viya platform pods. These new environment variables tell the SAS Viya platform where to look for the Python and R executables and associated libraries.

If you have licensed SAS/IML, you also need to create two new environment variables to enable R to be called by PROC IML in a SAS Program (for details, see [SAS Documentation on the RLANG system option](https://documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=default&docsetId=lesysoptsref&docsetTarget=p0bn69osmt5vogn1x07dth3als71.htm)):

1. `R_HOME` must point to `{{ r-parent-directory }}/lib/R` within your mounted R directory (for example, `/r-mount/lib/R` if R is mounted to `/r-mount`).
2. The `SASV9_OPTION` environment variable must be set to `=-RLANG`

You can automate the creation of these two environment variables by adding them to `$deploy/site-config/sas-open-source-config/r/kustomization.yaml`, or after deploying your updates by adding them within the SAS Environment Manager GUI.

For both Python and R, you also need to create a single new XML file with the "External languages settings". This is required for FCMP and PROC TSMODEL’s EXTLANG package.

### 6. Configure External Access to CAS

By default, CAS resources can be accessed by Python and R from within the cluster, but not external to the cluster. To access CAS resources outside the cluster (such as from an existing JupyterHub deployment elsewhere or from a desktop installation of R-Studio), additional configuration steps are required to enable binary (recommended) access. For details, see the README at `$deploy/sas-bases/examples/cas/configure/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configuration_settings_for_cas.htm` (for HTML format). See also [SAS Viya Platform Operations: Configure External Access to CAS](https://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=n08u2yg8tdkb4jn18u8zsi6yfv3d.htm#n0exq3y1b5gs73n18vi9o78y2dg3).

External connections to the SAS Viya platform, including CAS, can be made using resources that SAS provides for developers, open-source programmers, and system administrators who want to leverage or manage the computational capabilities of the SAS Viya platform but from open-source coding interfaces. See the [SAS Developer Home page](https://developer.sas.com/home.html) for up-to-date information about the different collections of resources, such as [code libraries and APIs for building apps with SAS](https://developer.sas.com/guides/open-source-sas.html), [SAS Viya Platform and CAS REST APIs](https://developer.sas.com/guides/rest.html), and [end-to-end example API use cases](https://developer.sas.com/guides/api-end-to-end.html).

### 7. Configure SAS Model Repository Service for Python and R Models

The SAS Viya platform must be configured to enable users to register and publish open-source models in the SAS Viya platform. For details and configuration options, see the following resources:

- Deployment READMEs:
  - For Python, see the README at `$deploy/sas-bases/examples/sas-model-repository/python/README.md` (for Markdown format) or at `$deploy/sas-bases//docs/configure_python_for_sas_model_repository_service.htm` (for HTML format).
  - For R, see the README at `$deploy/sas-bases/examples/sas-model-repository/r/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_rpy2_for_sas_model_repository_service.htm` (for HTML format).
  - For Git, see the README at `$deploy/sas-bases/examples/sas-model-publish/git/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/onfigure_git_for_sas_model_publish_service.htm` (for HTML format).
  - For Kaniko, see `$deploy/sas-bases/examples/sas-model-publish/kaniko/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_kaniko_for_sas_model_publish_service.htm` (for HTML format).
  
- [SAS Viya Platform: Publishing Destinations](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calpubdest&docsetTarget=n1i7t4fs3kdr88n1uj6h47e39w1b.htm)
- [SAS Viya Platform: Models Administration -- Configuring Support for Open-Source Models](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calmodels&docsetTarget=n11vwdrly0qi10n1pq1h13t890e2.htm)
- [SAS Model Manager: Administrator's Guide -- Configuring Support for Python Code Files](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrag&docsetTarget=p1pux2up89u0nln1fub8zb2aqets.htm)
- [SAS GitHub: model-management-resources](https://github.com/sassoftware/model-management-resources/tree/main/addons)

### 8. Configure Git Integration in SAS Studio

The SAS Viya platform allows direct integration with Git within the SAS Studio interface. Follow the steps outlined in the following resources:

- [SAS Studio Administrator's Guide: Configuration Properties for Git Integration](https://documentation.sas.com/?cdcId=webeditorcdc&cdcVersion=default&docsetId=webeditorag&docsetTarget=p1a2vn20wzwkumn1freonkz81mx5.htm) identifies the relevant configuration properties to enable Git integration
- [SAS Studio Administrator's Guide: General Configuration Properties](https://documentation.sas.com/?cdcId=webeditorcdc&cdcVersion=default&docsetId=webeditorag&docsetTarget=n0kxc7fd8os3nbn14nrddoli75x2.htm) provides configuration properties that are required for Git functionality to work -- namely, the `sas.studio.showServerFiles` property. To specify the directory path for the root node in the Folders tree in SAS Studio, edit the `sas.studio.fileNavigationCustomRootPath` and `sas.studio.fileNavigationRoot` properties

The configuration properties can be edited within the SAS Environment Manager console, or by using the [SAS Viya Platform Command Line Interface tool's](https://documentation.sas.com/doc/en/sasadmincdc/default/calcli/n01xwtcatlinzrn1gztsglukb34a.htm) [Configuration plug-in](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calconfig&docsetTarget=p0rtltqk08n6y6n1hts1n4ypqfao.htm).

## Additional Resources

The following links were referenced in this README or provide further useful information:

- [SAS Viya Platform: Deployment Guide -- Manual Deployment](https://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=p127f6y30iimr6n17x2xe9vlt54q.htm)
- [SAS Viya Platform Operations: Configure External Access to CAS](https://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=n08u2yg8tdkb4jn18u8zsi6yfv3d.htm#n0exq3y1b5gs73n18vi9o78y2dg3)
- [Python-SWAT GitHub repository](https://github.com/sassoftware/Python-swat/)
- [R-SWAT GitHub repository](https://github.com/sassoftware/R-swat/)
- [SAS Developer Home page](https://developer.sas.com/home.html) -- includes resources for SAS developers who want to integrate open-source tools; developers who want to leverage the SAS Viya platform capabilities; and systems administrators who want to use APIs to manage their SAS Viya platform deployment

## Table of Capabilities and READMEs

The following table maps each specific open-source integration point to the relevant resource(s) containing details about configuring that specific integration point.

| README | PROC Python   | PROC FCMP (Python)| PROC IML (R) | Open Source Code Node (Python) | Open Source Code Node (R) | EXTLANG Package (Python) | EXTLANG Package (R) | SWAT (Python & R) |
| ---         | :---:           | :---:              | :---:          | :---:                            | :---: | :---: | :---: | :---: |
| Python configuration | x | x | | x | | x
| R configuration |  | | x | | x | | x |
| Lockdown methods |  x | x |  | x |  | x |  | |
| External access to CAS | | | | | | | | x |

Python configuration: see the README at `$deploy/sas-bases/examples/sas-open-source-config/python/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_python_for_sas_viya_using_a_kubernetes_persistent_volume.htm` (for HTML format).

R configuration: see the README at `$deploy/sas-bases/examples/sas-open-source-config/r/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_r_for_sas_viya.htm` (for HTML format).

Lockdown methods: See the README at `$deploy/sas-bases/examples/sas-programming-environment/lockdown/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/lockdown_settings_for_the_sas_programming_environment.htm` (for HTML format).

External access to CAS: See the README at `$deploy/sas-bases/examples/cas/configure/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configuration_settings_for_cas.htm` (for HTML format).