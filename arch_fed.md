[//]: # ( vim: set wrap : )

# Federated Front-ends

OpenNebula federation feature has proven to be stable and reliable over the years. It allows users to construct a single federated cluster out of multiple smaller OpenNebula instances (HA or non-HA). The idea behind this feature is to provide architecture similar to AWS' Availability Zones.

> [!NOTE]
> You can learn more about **OpenNebula Data Center Federation** → [here](https://docs.opennebula.io/stable/installation_and_configuration/data_center_federation/index.html).

## Architecture

```
                 ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐
                 │ Master Front-end (HA)            │
                 │ ┌────────┐ ┌────────┐ ┌────────┐ │
                 │ │        │ │        │ │        │ │
                 │ │  ON-1  │─│  ON-2  │─│  ON-3  │ │
                 │ │        │ │        │ │        │ │
                 │ └────────┘ └───┬────┘ └────────┘ │
                 │                │ VIP 10.2.50.111 │
                 │          ┌─────┴──────┐          │
                 │     ┌────┴───┐    ┌───┴────┐     │
                 │     │        │    │        │     │
                 │     │ KVM-01 │    │ KVM-02 │     │
                 │     │        │    │        │     │
                 │     └────────┘    └────────┘     │
                 └ ─ ─ ─ ─ ─ ─ ─ ─ ┬ ─ ─ ─ ─ ─ ─ ─ ─┘
                                   │
                   ┌────── Backbone Network ───────┐
                   │                               │
 ┌ ─ ─ ─ ─ ─ ─ ─ ─ ┴ ─ ─ ─ ─ ─ ─ ─ ─┐  ┌ ─ ─ ─ ─ ─ ┴ ─ ─ ─ ─ ─ ─ ─┐
 │ Slave Front-end (HA)             │  │ Slave Front-end (non-HA) │
 │ ┌────────┐ ┌────────┐ ┌────────┐ │  │        ┌────────┐        │
 │ │        │ │        │ │        │ │  │        │        │        │
 │ │  ON-1  │─│  ON-2  │─│  ON-3  │ │  │        │  ON-1  │        │
 │ │        │ │        │ │        │ │  │        │        │        │
 │ └────────┘ └───┬────┘ └────────┘ │  │        └───┬────┘        │
 │                │ VIP 10.2.50.122 │  │            │             │
 │          ┌─────┴──────┐          │  │      ┌─────┴──────┐      │
 │     ┌────┴───┐    ┌───┴────┐     │  │ ┌────┴───┐    ┌───┴────┐ │
 │     │        │    │        │     │  │ │        │    │        │ │
 │     │ KVM-01 │    │ KVM-02 │     │  │ │ KVM-01 │    │ KVM-02 │ │
 │     │        │    │        │     │  │ │        │    │        │ │
 │     └────────┘    └────────┘     │  │ └────────┘    └────────┘ │
 └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
```

## Ansible Role

The `opennebula` one-deploy role is responsible for creating federated OpenNebula clusters. There are two deployment types you can try:

- **Sequential** (recommended), where each peer in the federation is deployed from its own inventory file in a sequence of `ansible-playbook` invocations.
- **Parallel**, where all peers are deployed from a single (slightly more complex) inventory file in a single `ansible-playbook` invocation.

> [!WARNING]
> Parallel deployment is slighly more experimental and limiting, for example Ceph deployment is not supported in this mode.

> [!WARNING]
> Currently Prometheus provisioning has been disabled (in precheck) for both deployment modes, this will be likely mitigated however after future OpenNebula releases are out (>= 6.8.3).

### Sequential Provisioning

To deploy federated OpenNebula cluster similar to the one depicted on the architecture diagram above you'll need three inventory files:

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebula
    one_version: '6.8'
    vn:
      service:
        managed: true
        template:
          VN_MAD: bridge
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 10.2.50.200
            SIZE: 10
          NETWORK_ADDRESS: 10.2.50.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 10.2.50.1
          DNS: 10.2.50.1
    one_vip: 10.2.50.111
    one_vip_cidr: 24
    one_vip_if: br0
    force_master: true
    zone_name: OpenNebula

frontend:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1b1: { ansible_host: 10.2.50.20 }

node:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1b1: { ansible_host: 10.2.50.20 }
```

> [!IMPORTANT]
> The `force_master: true` **must** be provided to prepare the master Front-end for adding more Front-ends to the federation later.

> [!IMPORTANT]
> When deployed with one-deploy, the master `zone_name` **must** be `OpenNebula` (which is the default anyway).

> [!IMPORTANT]
> The `federation` ansible group **must** be undefined for the master Front-end.

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebula
    one_version: '6.8'
    vn:
      service:
        managed: true
        template:
          VN_MAD: bridge
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 10.2.50.210
            SIZE: 10
          NETWORK_ADDRESS: 10.2.50.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 10.2.50.1
          DNS: 10.2.50.1
    one_vip: 10.2.50.122
    one_vip_cidr: 24
    one_vip_if: br0
    zone_name: Slave1

federation:
  hosts:
    master: { ansible_host: 10.2.50.111 }

frontend:
  hosts:
    n1a2: { ansible_host: 10.2.50.11 }
    n1b2: { ansible_host: 10.2.50.21 }

node:
  hosts:
    n1a2: { ansible_host: 10.2.50.11 }
    n1b2: { ansible_host: 10.2.50.21 }
```

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebula
    one_version: '6.8'
    vn:
      service:
        managed: true
        template:
          VN_MAD: bridge
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 10.2.50.220
            SIZE: 10
          NETWORK_ADDRESS: 10.2.50.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 10.2.50.1
          DNS: 10.2.50.1
    zone_name: Slave2

federation:
  hosts:
    master: { ansible_host: 10.2.50.111 }

frontend:
  hosts:
    n1a3: { ansible_host: 10.2.50.12 }

node:
  hosts:
    n1a3: { ansible_host: 10.2.50.12 }
    n1b3: { ansible_host: 10.2.50.22 }
```

> [!IMPORTANT]
> The `zone_name` variable **must** be defined for each slave for the **sequential** deployment mode.

> [!IMPORTANT]
> The `federation` ansible group **must** be defined for slave Front-ends, where the **first** inventory host is assumed to be the master Front-end (in HA master case, the `ansible_host` variable should point to the VIP address).

Next you need to execute `ansible-playbook` commands in a sequence:

```shell
$ make I=inventory/master.yml
```

```shell
$ make I=inventory/slave1.yml
```

```shell
$ make I=inventory/slave2.yml
```

### Parallel Provisioning

You can achieve similar result to the **sequential** one above, defining a single inventory file as follows:

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebula
    one_version: '6.8'

###

_0:
  children:
    ? frontend0
    ? node0
  vars:
    zone_name: OpenNebula
    vn:
      service:
        managed: true
        template: &template
          VN_MAD: bridge
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 10.2.50.200
            SIZE: 10
          NETWORK_ADDRESS: 10.2.50.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 10.2.50.1
          DNS: 10.2.50.1
    one_vip: 10.2.50.111
    one_vip_cidr: 24
    one_vip_if: br0

frontend0:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1b1: { ansible_host: 10.2.50.20 }

node0:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1b1: { ansible_host: 10.2.50.20 }

###

_1:
  children:
    ? frontend1
    ? node1
  vars:
    zone_name: Slave1
    vn:
      service:
        managed: true
        template:
          <<: *template
          AR:
            TYPE: IP4
            IP: 10.2.50.210
            SIZE: 10
    one_vip: 10.2.50.122
    one_vip_cidr: 24
    one_vip_if: br0

frontend1:
  hosts:
    n1a2: { ansible_host: 10.2.50.11 }
    n1b2: { ansible_host: 10.2.50.21 }

node1:
  hosts:
    n1a2: { ansible_host: 10.2.50.11 }
    n1b2: { ansible_host: 10.2.50.21 }

###

_2:
  children:
    ? frontend2
    ? node2
  vars:
    zone_name: Slave2
    vn:
      service:
        managed: true
        template:
          <<: *template
          AR:
            TYPE: IP4
            IP: 10.2.50.220
            SIZE: 10

frontend2:
  hosts:
    n1a3: { ansible_host: 10.2.50.12 }

node2:
  hosts:
    n1a3: { ansible_host: 10.2.50.12 }
    n1b3: { ansible_host: 10.2.50.22 }

###

frontend:
  children:
    ? frontend0
    ? frontend1
    ? frontend2

node:
  children:
    ? node0
    ? node1
    ? node2
```

> [!NOTE]
> This deployment mode is not 100% parallel, but tries to execute tasks in parallel as much as possible.

> [!NOTE]
> If you don't provide `zone_name` for slave Front-ends then `frontend1`, `frontend2`, ... names will be assumed.

> [!IMPORTANT]
> You **must** replicate the inventory structure above exactly, with the exception for `_X` group names, that can be any names really as they are used to apply common variables to both `frontendX` and `nodeX` groups.

And finally you can provision your federated environment in a single step as follows:

```shell
$ make I=inventory/parallel.yml
```
