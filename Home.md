# OpenNebula Ansible Playbooks Documentation

The OpenNebula Ansible project consists of a set of playbooks and roles that let you deploy an OpenNebula cloud in a simple and convinient way.

The documentation is organized based on three distinct architectures. We will start with the most straightforward architecture and gradually move towards more complex scenarios. For each scenario, we will provide concise explanations of the configurations implemented on both the platform and OpenNebula.

## Contents

* [Using the playbooks](sys_use)
* Deployments
  * [Local storage](arch_single_local)
  * [Shared storage](arch_single_shared)
  * [High availability front-ends](arch_ha)
  * [Connect through a bastion host](arch_bastion)
  * [Other configurations](arch_other)
* [Verifying the installation](sys_verify)

## Requirements

* Ansible version >= 2.14.0
* SSH access to the inventory servers, either directly or through a bastion host
* User used to connect to the servers can sudo into root
* Servers need to be configured to use either Netplan or NetworkManager

## How to use the OpenNebula Ansible Playbooks

The easiest way to use the playbooks is by cloning the [GitHub project](https://github.com/OpenNebula/one-deploy.git). Throught out this documentation we will refer to several files in the project tree and assume they are avialble to you.

```shell
$ git clone https://github.com/OpenNebula/one-deploy.git
```
For more advance users, the playbooks are available as part of the [Ansible Galaxy community site](https://galaxy.ansible.com/opennebula/cloud), just take a look at the documentation of each role in the OpenNebula collection to include them in your own playbooks.

