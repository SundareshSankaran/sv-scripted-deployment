---
category: sasProgrammingEnvironment
tocprty: 5
---

# LOCKDOWN Settings for the SAS Programming Environment

## Overview

This document describes the customizations that can be made by the Kubernetes
administrator for managing the settings for the LOCKDOWN feature in the
SAS Programming Environment.

For more information about LOCKDOWN, see
[LOCKDOWN System Option](https://go.documentation.sas.com/?docsetId=calsrvpgm&docsetTarget=p04d9diqt9cjqnn1auxc3yl1ifef.htm&docsetVersion=v_008&locale=en&showBanner=walkup#p0sshm6ekdjiafn1jm5o0as6dsdr).

## Installation

Read the descriptions for the example files in the following list. If you
want to use an example file to simplify customizing your deployment, copy
the file to your `$deploy/site-config` directory.

Each file has information about its content. The variables in the file are set
off by curly braces and spaces, such as {{ AMOUNT-OF-STORAGE }}. Replace the
entire variable string, including the braces, with the value you want to use.

After you edit a file, add a reference to it in the transformers block of the
base `kustomization.yaml` file.

Here is an example using the enable LOCKDOWN access methods transformer, saved
to `$deploy/site-config/sas-programming-environment/lockdown`:

```yaml
  transformers:
  ...
  - /site-config/sas-programming-environment/lockdown/enable-lockdown-access-methods.yaml
  ...
  ```

## Examples

The default behavior allows the following access methods to be enabled via
LOCKDOWN:

- HTTP
- EMAIL
- FTP
- HADOOP
- JAVA

These settings can be toggled using the transformers in the example files.
The example files are located at
 `$deploy/sas-bases/examples/sas-programming-environment/lockdown`.

- To enable access methods not included in the list above, such as PYTHON or
PYTHON_EMBED, replace {{ ACCESS-METHOD-LIST }}
in `enable-lockdown-access-methods.yaml`. For example,

```yaml
...
patch : |-
  - op: add
    path: /data/VIYA_LOCKDOWN_USER_METHODS
    value: "python python_embed"
...
```

**NOTE:** The names of the access methods are case-insensitive.

- To disable access methods from the default list, such as JAVA, replace
the {{ ACCESS-METHOD-LIST }} in `disable-lockdown-access-methods.yaml` with a list
of values to remove.  For example,

```yaml
...
patch : |-
  - op: add
    path: /data/VIYA_LOCKDOWN_USER_DISABLED_METHODS
    value: "java"
...
```

**NOTE:** The names of the access methods are case-insensitive.

## Additional Resources

For more information about deployment and using example files, see the
[SAS Viya Platform: Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm).