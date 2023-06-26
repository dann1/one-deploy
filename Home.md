# OpenNebula Ansible Playbooks Documentation

The OpenNebula Ansible project consists of a set of playbooks and roles that let you deploy an OpenNebula cloud in a simple and convinient way.

The documentation is organized based on four distinct architectures. We will start with the most straightforward architecture and gradually move towards more complex scenarios. For each scenario, we will provide concise explanations of the configurations implemented on both the platform and OpenNebula.

## Requirements

* Ansible version >= 2.14.0
* SSH access to the inventory servers, either directly or through a bastion host
* User used to connect to the servers can sudo into root

## How to use the OpenNebula Ansible Playbooks

The easiest way to use the playbooks is by cloning the [GitHub project](https://github.com/OpenNebula/one-deploy.git). Throught out this documentation we will refer to several files in the project tree and assume they are avialble to you.

```shell
$ git clone https://github.com/OpenNebula/one-deploy.git
```
For more advance users, the playbooks are available as part of the [Ansible Galaxy community site](https://galaxy.ansible.com/opennebula/cloud), just take a look at the documentation of each role in the OpenNebula collection to include them in your own playbooks.

## Supported Architecture Deployments

Please refer to each guide to deploy one of the following cloud architectures:

* [Single OpenNebula front-end and local storage](arch_single_local)
* [Single OpenNebula front-end and shared storage](arch_single_shared)
* [Front-end in HA configuration](arch_ha)

## Connecting to the Infrastructure through a Bastion host

TBD
