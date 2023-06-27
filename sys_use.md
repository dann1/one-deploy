# Requirements & Use

## Platform Notes

The playbooks are tested and verify on the following systems:

| Platform               | Notes                    |
| ---------------------- | ------------------------ |
| Ubuntu 22.04           | Netplan version > 0.105  |
| RHEL 9 and derivatives | NetworkManager required  |

## Requirements

* Ansible version >= 2.14.0
* SSH access to the inventory servers, either directly or through a bastion host
* User used to connect to the servers can sudo into root

## Using the GitHub Project

The easiest way to use the playbooks is by cloning the [GitHub project](https://github.com/OpenNebula/one-deploy.git). Throught out this documentation we will refer to several files in the project tree and assume they are avialble to you.

```shell
$ git clone https://github.com/OpenNebula/one-deploy.git
```

## Using the Ansible Galaxy Collection

For more advance users, the playbooks are available as part of the [Ansible Galaxy community site](https://galaxy.ansible.com/opennebula/cloud), just take a look at the documentation of each role in the OpenNebula collection to include them in your own playbooks.

