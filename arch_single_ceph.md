# Single Front-end & Ceph Storage

This scenario is a variation of the [shared storage](https://github.com/OpenNebula/one-deploy/wiki/arch_single_shared/) setup. Here, the storage for virtual machines (VMs) and the image repository are provided by a local Ceph cluster. Running VMs directly from Ceph storage can enhance the fault tolerance of the system in the event of a host failure, although it comes with the drawback of increased I/O latency.

## Inventory

### Dedicated (Non-HCI)

In this scenario Ceph OSD servers are deployed on dedicated hosts. Please refer to the documentation of the [ceph-ansible](https://docs.ceph.com/projects/ceph-ansible/en/latest/) project and to the group variable definions inside its [official git repository](https://github.com/ceph/ceph-ansible/tree/main/group_vars) for the full guide on how to configure it.

:warning: **Note**: one-deploy uses only specific roles for the `ceph-ansible` project and introduces the `opennebula.deploy.ceph` playbook to be executed **before** the main deployment.

```yaml
---
all:
  vars:
    ansible_user: root
    one_version: '6.6'
    one_pass: opennebulapass
    features:
      # Enable the "ceph" feature in one-deploy.
      ceph: true
    ds:
      # Simple datastore setup - use built-in Ceph cluster for datastores 0 (system) and 1 (images).
      mode: ceph
    vn:
      admin_net:
        managed: true
        template:
          VN_MAD: bridge
          PHYDEV: eth0
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 172.20.0.100
            SIZE: 48
          NETWORK_ADDRESS: 172.20.0.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 172.20.0.1
          DNS: 1.1.1.1

frontend:
  hosts:
    f1: { ansible_host: 172.20.0.6 }

node:
  hosts:
    n1: { ansible_host: 172.20.0.7 }
    n2: { ansible_host: 172.20.0.8 }

ceph:
  children:
    ? mons
    ? mgrs
    ? osds
  vars: {}

mons:
  hosts:
    mon1: { ansible_host: 172.20.0.6, monitor_address: 172.20.0.6 }

mgrs:
  hosts:
    mgr1: { ansible_host: 172.20.0.6 }

osds:
  hosts:
    osd1: { ansible_host: 172.20.0.10 }
    osd2: { ansible_host: 172.20.0.11 }
    osd3: { ansible_host: 172.20.0.12 }
```

### Hyper-Converged (HCI)

In this scenario we deploy Ceph OSD servers along the OpenNebula KVM nodes. Here, we limit and reserve CPU and RAM for Ceph OSDs to ensure
they interfere with the running guest VMs as lightly as possible.

:warning: **Note**: The exact amount of CPU and RAM depends on the size of the specific OSD, please refer to the Ceph documentation to calculate these.

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebulapass
    one_version: '6.6'
    features:
      # Enable the "ceph" feature in one-deploy.
      ceph: true
    ds:
      # Simple datastore setup - use built-in Ceph cluster for datastores 0 (system) and 1 (images).
      mode: ceph
    vn:
      admin_net:
        managed: true
        template:
          VN_MAD: bridge
          PHYDEV: eth0
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 172.20.0.200
            SIZE: 48
          NETWORK_ADDRESS: 172.20.0.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 172.20.0.1
          DNS: 172.20.0.1

frontend:
  hosts:
    f1: { ansible_host: 172.20.0.6 }

node:
  hosts:
    n1: { ansible_host: 172.20.0.7 }
    n2: { ansible_host: 172.20.0.8 }
    n3: { ansible_host: 172.20.0.9 }

ceph:
  children:
    ? mons
    ? mgrs
    ? osds
  vars:
    osd_memory_target: 4294967296 # 4GiB (default)
    # Assuming all osds are of equal size, setup resource limits and reservations for all osd systemd services.
    ceph_osd_systemd_overrides:
      Service:
        CPUWeight: 200 # 100 is the kernel default
        CPUQuota: 100% # 1 full core
        MemoryMin: "{{ (0.75 * osd_memory_target) | int }}"
        MemoryHigh: "{{ osd_memory_target | int }}"
    # Make sure osds preserve memory if it's below the value of the "osd_memory_target" fact.
    ceph_conf_overrides:
      osd:
        ? osd memory target
        : "{{ osd_memory_target | int }}"

mons:
  hosts:
    f1: { ansible_host: 172.20.0.6, monitor_address: 172.20.0.6 }

mgrs:
  hosts:
    f1: { ansible_host: 172.20.0.6 }

osds:
  hosts:
    # NOTE: The Ceph osds are deployed along the OpenNebula KVM nodes (HCI setup).
    n1: { ansible_host: 172.20.0.7 }
    n2: { ansible_host: 172.20.0.8 }
    n3: { ansible_host: 172.20.0.9 }
```

## Local Ceph cluster deployment

The one-deploy project comes with the `opennebula.deploy.ceph` playbook that can be executed as follows:

```shell
$ ansible-playbook -i inventory/ceph.yml opennebula.deploy.ceph
```

The Ceph-related part of the inventory can be identfied as shown below (please refer to the `ceph-ansible`'s documentation for the full guide on how to configure `ceph-*` roles).

```yaml
ceph:
  children:
    ? mons
    ? mgrs
    ? osds
  vars: {}

mons:
  hosts:
    mon1: { ansible_host: 172.20.0.6, monitor_address: 172.20.0.6 }

mgrs:
  hosts:
    mgr1: { ansible_host: 172.20.0.6 }

osds:
  hosts:
    osd1: { ansible_host: 172.20.0.10 }
    osd2: { ansible_host: 172.20.0.11 }
    osd3: { ansible_host: 172.20.0.12 }
```

## Running the Ansible Playbooks

* **1. Prepare the inventory file**: Update the `ceph.yml` file in the inventory file to match your infrastructure settings. Please be sure to update or review the following variables:
  - `ansible_user`, update it if different from root
  - `one_pass`, change it to the password for the oneadmin account
  - `one_version`, be sure to use the latest stable version here
  - `features.ceph`, to enable Ceph in one-deploy
  - `ds.mode`, to confgure Ceph datastores in OpenNebula

* **2. Check the connection**: Verify the network connection, ssh and sudo configuration run the following command:
```shell
ansible -i inventory/ceph.yml all -m ping -b
```
* **3. Site installation**: Now we can run the site playbooks that provision a local Ceph cluster install and configure OpenNebula services
```shell
ansible-playbook -i inventory/ceph.yml opennebula.deploy.ceph opennebula.deploy.main
```
Once the execution of the playbooks finish your new OpenNebula cloud is ready. [You can now head to the verification guide](sys_verify).
