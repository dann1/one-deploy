# Deployment via Bastion Host

In some cases direct access from Ansible controller to targets in the inventory is not possible or difficult. You can use the `bastion` role to construct custom SSH config out of your inventory, then provision your hosts automatically through a SSH jump host.

## Preparing inventory

To enable the `bastion` role you need to add several parameters to your inventory file:

```yaml
all:
  vars:
    env_name: n1
    ansible_ssh_common_args: -F inventory/.one-deploy/bastion.d/n1
    ansible_user: ubuntu
    one_vip: 10.2.50.86
```

Where `env_name` is used to distinguish between different OpenNebula clusters and `-F inventory/.one-deploy/bastion.d/n1` points to the pre-generated SSH config used later by all plays during provisioning.


```yaml
bastion:
  hosts:
    n1: { ansible_host: 10.2.50.123 }

frontend:
  hosts:
    n1a1: { ansible_host: n1a1 }
    n1a2: { ansible_host: n1a2 }
    n1a3: { ansible_host: n1a3 }

node:
  hosts:
    n1b1: { ansible_host: n1b1 }
    n1b2: { ansible_host: n1b2 }

grafana:
  hosts:
    n1a1: { ansible_host: n1a1 }
```

The `bastion` group should contain a single host accessible from you Ansible controller. This host can for example be one of the Frontends or something completely from outside of the cluster.

## SSH configs

You can manage multiple clusters from a single inventory dir:

```
one-deploy$ find inventory/.one-deploy/ -type f
inventory/.one-deploy/bastion.d/n2
inventory/.one-deploy/bastion.d/n1
inventory/.one-deploy/bastion
```

Looking at `inventory/.one-deploy/bastion.d/n1`, resulting SSH config should be really straightforward to understand:

```ssh-config

Host n1
  Hostname 10.2.50.123
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes


# one_vip
Host 10.2.50.86
  Hostname 10.2.50.86
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes
  ProxyJump n1


Host n1a1
  Hostname n1a1
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes
  ProxyJump n1

Host n1a2
  Hostname n1a2
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes
  ProxyJump n1

Host n1a3
  Hostname n1a3
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes
  ProxyJump n1

Host n1b1
  Hostname n1b1
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes
  ProxyJump n1

Host n1b2
  Hostname n1b2
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ForwardAgent yes
  ProxyJump n1

```

## SSH keys

The main requirement for all this to work, is that you can connect to the bastion host and then further to all host specified in the inventory. The easiest way to achieve that is to use `ssh-agent`, but you can also store private keys inside the bastion host (if you must).