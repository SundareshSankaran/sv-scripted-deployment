---
category: SAS Configurator for Open Source
tocprty: 1
---

# SAS Configurator for Open Source Options

## Overview

SAS Configurator for Open Source is a utility application that simplifies the download, configuration, building, and installation of Python and R from source. The results are a Python and R build that is located in a Persistent Volume Claim (PVC). The PVC and the builds that it contains are then referenced by pods that require Python and R for their operations.

SAS Configurator for Open Source includes the ability to build and install multiple Python and R builds or versions in the same PVC. In order to handle multiple builds, it uses profiles, which are discussed later in this document. Various pods can reference different versions or builds of Python and R located in the PVC.

SAS Configurator for Open Source also includes functionality to reduce downtime associated with updates. A given build is located in the PVC and then referenced by a pod using a symlink. In an update scenario, the symlink is changed to point to the latest build for that profile.

**Note:** The operating system within most SAS Viya platform containers, including the SAS Configurator for Open Source, is the latest available released version of Red Hat Universal Base Image 8 (UBI8). This means that the Python and R installations created by the SAS Configurator for Open Source will execute on an operating system compatible with Red Hat UBI8. This also means that any third-party binaries need to be UBI8 compatible to execute properly within SAS Viya platform UBI8 based containers.

## Summary of Steps

Building Python or R requires a number of steps. This section describes the steps performed by SAS Configurator for Open Source in its operation respective to Python and R.

### Download

For Python, downloads the source, signature file, and signer's key from the configured location. For R, only the source is downloaded.

### Verify

Verifies the authenticity of the Python source using the signer's key and signature file. The R source cannot be verified at the time of this writing because signer keys are not generated for R source.

### Extract

Extracts the Python and R sources into a temporary directory for building.

### Build

Configures and performs a make of the Python and R sources.

### Installation

Installs the Python and R builds within the PVC and updates supporting components, such as PIP, if applicable.

### Installation of Packages

Builds and installs configured packages for Python and R.

### SAS Configurator for Open Source Updates

If everything has completed successfully, creates the symbolic links, or changes the symbolic links' targets to point to the latest builds for both Python and R.

## Instructions

### Manual Job Execution

If you deployed your software using the Kubernetes command option, you should execute the job manually. Execute this command:

```yaml
kubectl create job -n <namespace> --from=cronjob/sas-pyconfig <jobname>
```

where namespace is the name of the namespace for the deployment and jobname is the name of the job to create from the CronJob.

### Enable SAS Configurator for Open Source with the Default Configuration at Deployment

The directory `$deploy/sas-bases/examples/sas-pyconfig` contains an example file,
change-configuration.yaml. The example file contains the default options that are described in this README file. Take these steps to run with the default settings:

1. Copy `$deploy/sas-bases/examples/sas-pyconfig/change-configuration.yaml` to `$deploy/site-config/sas-pyconfig/change-configuration.yaml`.

2. Edit `$deploy/site-config/sas-pyconfig/change-configuration.yaml` and change the value of global.enabled from `false` to `true`. If you are enabling Python, change the value of global.python_enabled from `false` to `true`. If you are enabling R, change the value of global.r_enabled from `false` to `true`.

3. Add `site-config/sas-pyconfig/change-configuration.yaml` to the `transformers`
   block of the base kustomization.yaml file (`$deploy/kustomization.yaml`).

   Here is an example:

   ```yaml
   ...
   transformers:
   ...
   - site-config/sas-pyconfig/change-configuration.yaml
   ```

### Enable SAS Configurator for Open Source with Custom Options at Deployment

The directory `$deploy/sas-bases/examples/sas-pyconfig` contains an example file named change-configuration.yaml. The example file contains the default options in this README file. To modify the default settings:

1. Copy `$deploy/sas-bases/examples/sas-pyconfig/change-configuration.yaml` to
   `$deploy/site-config/sas-pyconfig/change-configuration.yaml`.

2. Edit `$deploy/site-config/sas-pyconfig/change-configuration.yaml`.
   Change the value of `global.enabled` from `false` to `true`. Make the desired changes or additions to the options within the file.

    If you are configuring a new Python profile, the profile name must be placed in the `global.python_profiles` list, and all profile-specific options must be added to the file.
    If you are configuring a new R profile, the profile name must be placed in the `global.r_profiles` list, and all profile-specific options must be added to the file.

3. Add `site-config/sas-pyconfig/change-configuration.yaml` to the `transformers` block of the base kustomization.yaml file (`$deploy/kustomization.yaml`).

   Here is an example:

   ```yaml
   ...
   transformers:
   ...
   - site-config/sas-pyconfig/change-configuration.yaml
   ```

### Resource Management

SAS Configurator for Open Source requires more CPU and memory than most components. This requirement is largely due to Python and R building related operations such as those performed by configure and make. Since SAS Configurator for Open Source is disabled by default, pod resources are decreased so that they are not misallocated during scheduling. The default resource values are as follows:

```yaml
limits:
  cpu: 250m
  memory: 250Mi
requests:
  cpu: 25m
  memory: 25Mi
```

***Important:*** If the default values are used with SAS Configuration for Open Source enabled, pod execution will result in a OOMKilled (Out of Memory Killed) status in the pod list and will never execute to completion. The requests and limits must be increased in order for the pod to complete successfully.

If the environment does not use resource quotas, a CPU request value of 4000m and memory request value of 3000mi and no limits is a good starting point. No limits will allow the pod to use more than requested resources if they are available which can result in a quicker time to completion. With these values, the pod should complete its operations in approximately 15 mins and before the environment is stable of enough for wide spread use. Differences in hardware specifications will have an impact on the time it takes for the pod to complete.

If the environment uses resource quotas, limit values must be specified and equal to or greater than the respective request values for CPU and memory.

The values of requests and limits can be adjusted to meet specific needs of an environment. For example, those values can be reduced to allow scheduling within smaller environments or values can be increased to reduce the time associated with building multiple versions of Python and R.

1. Copy `$deploy/sas-bases/examples/sas-pyconfig/change-limits.yaml` to
`$deploy/site-config/sas-pyconfig/change-limits.yaml`.

2. Edit `$deploy/site-config/sas-pyconfig/change-limits.yaml` and change the values of CPU and memory accordingly. See examples that follow.

3. Add `site-config/sas-pyconfig/change-limits.yaml` to the `transformers` block of the base kustomization.yaml file (`$deploy/kustomization.yaml`).

   Here is an example:

   ```yaml
   ...
   transformers:
   ...
   - site-config/sas-pyconfig/change-limits.yaml
   ```

#### Resource Example 1

In this example, SAS Open Source Configuration is configured with a CPU request value of 4000m and memory request value of 3000mi. There is no limit to CPU and memory usage. This configuration should not be used in environments where resource quotas are in use.

```yaml
---
apiVersion: builtin
kind: PatchTransformer
metadata:
  name: sas-pyconfig-limits
patch: |-
  - op: replace
    path: /spec/template/spec/containers/0/resources/requests/cpu
    value:
      4000m
  - op: replace
    path: /spec/template/spec/containers/0/resources/requests/memory
    value:
      3000Mi
  - op: remove
    path: /spec/template/spec/containers/0/resources/limits/cpu
  - op: remove
    path: /spec/template/spec/containers/0/resources/limits/memory
target:
  group: batch
  kind: Job
  name: sas-pyconfig
  version: v1
#---
#apiVersion: builtin
#kind: PatchTransformer
#metadata:
#  name: sas-pyconfig-limits
#patch: |-
#  - op: replace
#    path: /spec/template/spec/containers/0/resources/requests/cpu
#    value:
#      4000m
#  - op: replace
#    path: /spec/template/spec/containers/0/resources/requests/memory
#    value:
#      3000Mi
#  - op: replace
#    path: /spec/template/spec/containers/0/resources/limits/cpu
#    value:
#      4000m
#  - op: replace
#    path: /spec/template/spec/containers/0/resources/limits/memory
#    value:
#      3000Mi
#target:
#  group: batch
#  kind: Job
#  name: sas-pyconfig
```

#### Resource Example 2

In this example, both requests and limits values for CPU and memory has been set to 4000m and 3000mi respectively. This configuration is could be used in an environment with resource quotas.

```yaml
#---
#apiVersion: builtin
#kind: PatchTransformer
#metadata:
#  name: sas-pyconfig-limits
#patch: |-
#  - op: replace
#    path: /spec/template/spec/containers/0/resources/requests/cpu
#    value:
#      4000m
#  - op: replace
#    path: /spec/template/spec/containers/0/resources/requests/memory
#    value:
#      3000Mi
#  - op: remove
#    path: /spec/template/spec/containers/0/resources/limits/cpu
#  - op: remove
#    path: /spec/template/spec/containers/0/resources/limits/memory
#target:
#  group: batch
#  kind: Job
#  name: sas-pyconfig
#  version: v1
---
apiVersion: builtin
kind: PatchTransformer
metadata:
  name: sas-pyconfig-limits
patch: |-
  - op: replace
    path: /spec/template/spec/containers/0/resources/requests/cpu
    value:
      4000m
  - op: replace
    path: /spec/template/spec/containers/0/resources/requests/memory
    value:
      3000Mi
  - op: replace
    path: /spec/template/spec/containers/0/resources/limits/cpu
    value:
      4000m
  - op: replace
    path: /spec/template/spec/containers/0/resources/limits/memory
    value:
      3000Mi
target:
  group: batch
  kind: Job
  name: sas-pyconfig
```

### Change the Configuration and Rerun the Job

You can change the configuration and run the SAS Configurator for Open Source job again without redeploying the SAS Viya platform.

1. Determine the exact name of the sas-pyconfig-parameters ConfigMap:

   ```bash
   kubectl get configmaps -n <name-of-namespace> | grep sas-pyconfig`
   ```

   The name will be something like sas-pyconfig-parameters-abcd1234.

2. Edit the ConfigMap using the following command:

   ```bash
   kubectl edit configmap <sas-pyconfig-parameters-configmap-name> -n <name-of-namespace>
   ```

   In this example, `sas-pyconfig-parameters-configmap-name` is the name of the ConfigMap from step 1. Change the value of `global.enabled` to `true` if it is set to `false`, and make the desired changes or additions to the options.

If you are configuring a new R profile, the profile name must be placed in the `global.r_profiles` list, and all profile-specific options must be added to the file. If you are configuring a new Python profile, the profile name must be placed in the `global.python_profiles` list, and all profile-specific options must be added to the file. Save the changes when finished.

3. Create a job from the configured cronjob.

   ```bash
   kubectl create job --namespace <name-of-namespace> --from cronjob/sas-pyconfig sas-pyconfig-job
   ```

4. A job pod is created that applies the changes made in the ConfigMap. The status of the pod can be viewed with
   `kubectl get pods -n <name-of-namespace> | grep sas-pyconfig-job`.

### Disable SAS Configurator for Open Source

By default, SAS Configurator for Open Source is disabled.

1. Determine the exact name of the sas-pyconfig-parameters ConfigMap:

   ```bash
   kubectl get configmaps -n <name-of-namespace> | grep sas-pyconfig`
   ```

   The name will be something like sas-pyconfig-parameters-abcd1234.

2. Edit the ConfigMap using the following command:

   ```bash
   kubectl edit configmap <sas-pyconfig-parameters-configmap-name> -n <name-of-namespace>
   ```

   In this example, `sas-pyconfig-parameters-configmap-name` is the name of the ConfigMap from step 1. Change the value of global.enabled to `false`.

3. SAS Configurator for Open Source will run during a deployment or update.

## Default Configuration and Options

The configuration options used by SAS Configurator for Open Source are referenced from the sas-pyconfig-parameters ConfigMap. This section describes the options
available in the ConfigMap, their meaning, and default values.

Configuration options fall into two main categories:

- global options

  Options that are applied across or related to all profiles and to the application.

- profile options

  Options that are specific to a profile.

A profile is synonymous with a specific Python or R installation. You might have many profiles based on various requirements within the environment. The predefined Python profile is named "default_py", and the predefined R profile is named "default_r". The default profiles are a starting point, and they might or might not fit your specific needs.

### Global Options

The options in this section are applicable to all profiles or to the application as a whole.

#### global.enabled

This global option effectively enables or disables the SAS Configurator for Open Source application.

This option must be changed to `true` in order to enable SAS Configurator for Open Source to work.

Default Value: `false`

#### global.python_enabled

This global option effectively enables or disables Python profile builds.

This option must be changed to `true` in order to enable Python to build.

Default Value: `false`

#### global.r_enabled

This global option effectively enables or disables R profile builds.

This option must be changed to `true` in order to enable R to build.

Default Value: `false`

#### global.status

This global option indicates the status of the SAS Configurator for Open Source job and is updated dynamically as conditions within the application change. Values could be `uninitialized`, `pending`, `error`, or `complete`. All of these values are self-explanatory.

There is no need to make changes to the value of this option because it is dynamic and is updated by the application.

Default Value: `uninitialized`

#### global.pvc

This global option specifies the mount point within the SAS Configurator for Open Source job pod. This is the location of PVC in the job pod and is the installation location of Python and R profiles.

There should be no need to change this value because the PVC is created by the SAS Configurator for Open Source application. If this value is changed, then the corresponding mount point of the PVC must be changed within the SAS Configurator for Open Source application pod.

Default Value: `/opt/sas/viya/home/sas-pyconfig`

#### global.python_profiles

This global option lists the Python profiles that will be configured by the SAS Configurator for Open Source. The list is space-delimited, with each profile corresponding to a list of profile-specific options.

If you are creating your own profile, change this value. A profile name can contain only alphanumeric characters with no spaces and should be descriptive. It should also be unique in the list of Python and R profiles. The profile name is used as the name for the symbolic link in update operations and will appear in the top level of the mount point configured by `global.pvc`.

For example, a profile name for Python version 3.6 may be python36. A profile for Python version 3.6 with no SASPy package may be called python36nosaspy. If you are continuing to use the default profile and you are adding one called python36, the value for this option would be `default python36`.

Default Value: `default_py`

#### global.r_profiles

This global option lists the R profiles that will be configured by the SAS Configurator for Open Source. The list is space-delimited, with each profile corresponding to a list of profile-specific options.

If you are creating your own profile, change this value. A profile name can contain only alphanumeric characters with no spaces and should be descriptive. It should also be unique in the list of Python and R profiles. The profile name is used as the name for the symbolic link in update operations and will appear in the top level of the mount point configured by `global.pvc`.

For example, a profile name for R version 4.2.0 may be r420. A profile for R version 4.2.0 with no httr package may be called r420nohttr. If you are continuing to use the default profile and you are adding one called r420nohttr, the value for this option would be `default r420nohttr`.

Default Value: `default_r`

### Profile Options

The options in this section are per-profile configuration options that must exist for each profile name in the list of global.profiles. When it is time to build the profiles that are defined in `global.profiles`, each of these options are referenced by profile name and specific option in the format `<profile-name>.<option-name>`.

#### `<profile-name>.configure_opts` for Python

These options are passed to the configure command that is used as part of the build of the Python process.

Unless you are experimenting, this value should not change. At minimum, SAS strongly recommends that `--enable-optimizations` remain in the list of configure options. The values that can be used in this option are the same as the options that are used on the command line for configure.

Default Value: `--enable-optimizations`

#### `<profile-name>.configure_opts` for R

These options are passed to the configure command that is used as part of the build of the R process.

The options --with-blas, --with-lapack, and --enable-BLAS-shlib are required for proper execution of R with the SAS Viya platform and must always be included in the list.

Default Value: `--enable-memory-profiling --enable-R-shlib --with-blas --with-lapack --with-readline=no --with-x=no --enable-BLAS-shlib`

#### `<profile-name>.cflags`

This option is passed to any command that needs `CFLAGS` set. Typically this option is used as part of the Python and R configure/build process.

Unless you are experimenting, this value should not change. At minimum, the value `-fPIC` must remain in the list of `CFLAG` options.

Default Value: `-fPIC`

#### `<profile-name>.pip_install_packages` for Python

A space-separated list of packages that will be installed by PIP. This is not a definitive list because a number of the packages in the default list have dependencies that are installed in order to satisfy their build and install requirements.

You can add and subtract packages in this list as desired.

The use of SSH/SCP is not a supported option for specifying packages. An example of using SSH/SCP is an entry in the format of git+ssh://user@repo. 

Default Value:
`Prophet sas_kernel matplotlib sasoptpy sas-esppy NeuralProphet scipy rpy2 Flask XGBoost TensorFlow pybase64 scikit-learn statsmodels sympy mlxtend Skl2onnx nbeats-pytorch ESRNN onnxruntime opencv-python zipfile38 json2 pyenchant nltk spacy gensim pyarrow hnswlib sas-ipc-queue`

#### `<profile-name>.packages` for R

A space-separated list of packages that will be installed for R. This is not a definitive list because a number of the packages in the default list have dependencies that are installed in order to satisfy their build and install requirements.

You can add and subtract packages in this list as desired.

The install_github and githubinstall functions are not supported and cannot be used to install R packages.

Default Value:
`dplyr jsonlite httr tidyverse randomForest xgboost forecast`

#### `<profile-name>.python_signer` for Python

The location of the signer's key. This key is provided by the signer of the source package you are downloading and used to verify the Python source is authentic. The value can change across versions of Python because the signer between versions can be different.

Default Value: `https://keybase.io/ambv/pgp_keys.asc`

#### `<profile-name>.python_signature` for Python

The location of the signature file for the Python tarball. This value is used in conjunction with the signer's key to validate the integrity of the Python source code that is downloaded. The value for this property will change when a different source tarball is used.

Default Value: `https://www.python.org/ftp/python/3.8.15/Python-3.8.15.tgz.asc`

#### `<profile-name>.python_tarball` for Python

The location of the Python tarball. This is Python source code that is built and installed into the PVC.

Default Value: `https://www.python.org/ftp/python/3.8.15/Python-3.8.15.tgz`

#### `<profile-name>.r_tarball` for R

The location of the R tarball. This is R source code that is built and installed into the PVC.

Default Value: `https://cloud.r-project.org/src/base/R-4/R-4.2.2.tar.gz`

## Example Patch File 1

This file contains the default profiles only.

```yaml
apiVersion: builtin
kind: PatchTransformer
metadata:
  name: sas-pyconfig-custom-parameters
patch: |-
  - op: replace 
    path: /data/global.enabled
    value: "false"
  - op: replace 
    path: /data/global.python_enabled
    value: "false"
  - op: replace 
    path: /data/global.r_enabled
    value: "false"
  - op: replace
    path: /data/global.pvc
    value: "/opt/sas/viya/home/sas-pyconfig"
  - op: replace
    path: /data/global.python_profiles
    value: "default_py"
  - op: replace
    path: /data/global.r_profiles
    value: "default_r"
  - op: replace
    path: /data/default_py.configure_opts
    value: "--enable-optimizations"
  - op: replace
    path: /data/default_r.configure_opts
    value: "--enable-memory-profiling --enable-R-shlib --with-blas --with-lapack --with-readline=no --with-x=no"
  - op: replace
    path: /data/default_py.cflags
    value: "-fPIC"
  - op: replace
    path: /data/default_r.cflags
    value: "-fPIC"
  - op: replace
    path: /data/default_py.pip_install_packages
    value: "Prophet sas_kernel matplotlib sasoptpy sas-esppy NeuralProphet scipy rpy2 Flask XGBoost TensorFlow pybase64 scikit-learn statsmodels sympy mlxtend Skl2onnx nbeats-pytorch ESRNN onnxruntime opencv-python zipfile38 json2 pyenchant nltk spacy gensim pyarrow hnswlib sas-ipc-queue"
  - op: replace
    path: /data/default_py.python_signer
    value: https://keybase.io/ambv/pgp_keys.asc
  - op: replace
    path: /data/default_py.python_signature
    value: https://www.python.org/ftp/python/3.8.15/Python-3.8.15.tgz.asc
  - op: replace
    path: /data/default_py.python_tarball
    value: https://www.python.org/ftp/python/3.8.15/Python-3.8.15.tgz
  - op: replace
    path: /data/default_r.r_tarball
    value: https://cloud.r-project.org/src/base/R-4/R-4.2.2.tar.gz
  - op: replace
    path: /data/default_r.packages
    value: "dplyr jsonlite httr tidyverse randomForest xgboost forecast"
target:
  version: v1
  kind: ConfigMap
  name: sas-pyconfig-parameters
```

## Example Patch File 2

This file adds a Python profile called "myprofile" to the list of global.profiles and creates profile options for "myprofile". Note that the default Python profile is still listed and will also be built.

```yaml
apiVersion: builtin
kind: PatchTransformer
metadata:
  name: sas-pyconfig-custom-parameters
patch: |-
  - op: replace
    path: /data/global.enabled
    value: "true"
  - op: replace
    path: /data/global.python_profiles
    value: "default myprofile"
  - op: add
    path: /data/myprofile.configure_opts
    value: "--enable-optimizations"
  - op: add
    path: /data/myprofile.cflags
    value: "-fPIC"
  - op: add
    path: /data/myprofile.pip_install_packages
    value: "Prophet sas_kernel matplotlib sasoptpy sas-esppy NeuralProphet scipy rpy2 Flask XGBoost TensorFlow pybase64 scikit-learn statsmodels sympy mlxtend Skl2onnx nbeats-pytorch ESRNN onnxruntime opencv-python zipfile38 json2 pyenchant nltk spacy gensim pyarrow hnswlib sas-ipc-queue"
  - op: add
    path: /data/myprofile.python_signer
    value: https://keybase.io/ambv/pgp_keys.asc
  - op: add
    path: /data/myprofile.python_signature
    value: https://www.python.org/ftp/python/3.8.15/Python-3.8.15.tgz.asc
  - op: add
    path: /data/myprofile.python_tarball
    value: https://www.python.org/ftp/python/3.8.15/Python-3.8.15.tgz
target:
  version: v1
  kind: ConfigMap
  name: sas-pyconfig-parameters
```