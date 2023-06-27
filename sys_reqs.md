# Platform Notes

The playbooks are tested and verified on the following systems:

| Platform               | Notes                    |
| ---------------------- | ------------------------ |
| Ubuntu 22.04           | Netplan version >= 0.105 |
| RHEL 9 and derivatives | NetworkManager required  |

# Requirements

* Ansible version >= 2.14.0
* SSH access to the inventory servers, either directly or through a bastion host
* User used to connect to the servers can sudo into root