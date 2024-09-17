[//]: # ( vim: set wrap : )

# Deploying a Single Front-end with Ceph Storage

The playbooks in OneDeploy offer the possibility of using a local Ceph cluster for storing the Virtual Machines (VMs) and the image repository. From the perspective of the OneDeploy inventory and OpenNebula configuration, this scenario is a variation of the [Shared Storage](arch_single_shared) setup, using Ceph instead of an NFS/NAS server. Running VMs directly from a Ceph cluster offers enhanced fault tolerance in the event of a host failure, at the expense of increased I/O latency.

To define the initial Ceph configuration, `one-deploy` uses the official Ceph Ansible playbook, which is called `ceph-ansible`. Only specific roles from `ceph-ansible` are used. Additionally, `one-depoy` introduces the `opennebula.deploy.ceph playbook`, which is run _before_ the main deployment.

For a detailed description of all available Ceph attributes and configurations, we recommend referring to the [official Ceph documentation](https://docs.ceph.com/projects/ceph-ansible/en/latest/).

> [!NOTE]
> To use Ceph with `one-deploy`, you will need to install `one-deploy` via the "direct clone" method, i.e. by cloning the repo using git. For details please see [Using the Playbooks](sys_use#downloading-the-playbooks).


## Prerequisites

The requirements to run the single-deployment Ceph integration are fundamentally the same as for deploying a Ceph cluster, with some special considerations:

- **Dedicated Servers**: You need dedicated servers to act as **OSDs** (Object Storage Daemons), **MONs** (Monitor Nodes), and **MGRs** (Manager Nodes). The number of nodes depends on your desired redundancy and performance requirements.
- **Disk Storage**: Each OSD node should have one or more disks dedicated to storing data. SSDs are recommended for journaling and metadata purposes, while HDDs or SSDs can be used for actual data storage. *These disks MUST be formatted and empty*, without any partition created.
- **Network Infrastructure**: A reliable and high-speed network infrastructure is crucial for efficient communication between nodes. This includes both public and cluster networks. You will also need to configure two networks to be used in the Ceph cluster:
    - A private network for a private communication between the nodes of the Cluster.
    - A public network to ensure that each node is accessible from the service network on which OpenNebula operates, or OpenNebula will not be able to communicate with the Ceph cluster.

## Configuring the Base Intenvory

This section briefly describes a typical workflow of the Ceph playbook, focusing on components such as OSDs (Object Storage Daemons), MONs (Monitor Nodes) and MGRs (Manager Nodes). These components will later be added to OpenNebula, implementing all functionality described for the [Ceph Datastore](https://docs.opennebula.io/stable/open_cluster_deployment/storage_setup/ceph_ds.html)in the OpenNebula documentation.

The typical basic steps are the following:

1. **Set up the inventory**: The playbook begins by defining the inventory, which includes details of all the servers that will be part of the Ceph cluster. This could include separate groups for OSD nodes, MON nodes, MGR nodes, and any other necessary infrastructure.

```yaml
ceph:
  children:
    ? mons
    ? mgrs
    ? osds
  vars:
    osd_auto_discovery: true

mons:
  hosts:
      stor01: {ansible_host: '10.255.0.1', monitor_address: '10.255.0.1'}
      stor02: {ansible_host: '10.255.0.2', monitor_address: '10.255.0.2'}
      stor03: {ansible_host: '10.255.0.3', monitor_address: '10.255.0.3'}

mgrs:
  hosts:
      osd01: {ansible_host: '10.255.0.1'}
      osd02: {ansible_host: '10.255.0.2'}
      osd03: {ansible_host: '10.255.0.3'}

osds:
  vars:
  hosts:
    osd01:
      ansible_host: 10.255.0.1
      devices:
        - /dev/disk/by-id/wwn-0x5000cca2e950aae0
        - /dev/disk/by-id/wwn-0x5000cca2e950a9f0
    osd02:
      ansible_host: '10.255.0.2'
      devices:
        - /dev/disk/by-id/wwn-0x5000cca2c0085778
        - /dev/disk/by-id/wwn-0x5000cca2c00589d0
       
    osd03:
      ansible_host: '10.255.0.3'
      devices:
        - /dev/disk/by-id/wwn-0x5000ccadcc008e2ec
        - /dev/disk/by-id/wwn-0x5000ccadc007e9043
```

> [!TIP]
> For details on these attributes, we recommend you check the [Ceph Ansible playbook documentation](https://docs.ceph.com/projects/ceph-ansible/en/latest/).

2. **Preparation**: Before deploying Ceph, the playbook may perform tasks to ensure that all necessary prerequisites are met on the target servers. This can involve installing required packages, configuring network settings, and ensuring that the servers have adequate resources.

3. **Deploy Ceph Components**:
    - **Deploy MONs**: The playbook starts by deploying the MON nodes. MONs are responsible for maintaining cluster membership and state. Ansible will typically install the necessary packages, generate and distribute authentication keys, and configure the MON nodes to communicate with each other.

    - **Deploy OSDs**: Once the MON nodes are up and running, the playbook proceeds to deploy the OSD nodes. OSDs are responsible for storing data in the Ceph cluster. Ansible will partition the disks and configure them to act as OSDs. It will then add the OSD nodes to the cluster and rebalance data across them.

    - **Deploy MGRs**: MGR nodes, or Manager nodes, are responsible for managing and monitoring the Ceph cluster. The playbook will deploy MGR nodes and configure them to collect and present cluster metrics, handle commands and requests from clients, and perform other management tasks.

4. **Configure the Cepch Cluster**: Once all necessary components are deployed, the playbook will perform any additional tasks required to finish configuring the Ceph cluster. This may include setting up placement groups (PGs), configuring pools, enabling features such as erasure coding or cache tiering, and optimizing performance settings. By default, one pool will be created with the name `one`.

## Additional Configurations per Use Case

Depending on each use case, additional configuration may be required to run the `one-deploy` playbook with the appropriate configuration for Ceph. This section lists the different use cases supported by `one-deploy`, with example configurations.

### Dedicated Hosts (Non-HCI)

In this scenario, the Ceph OSD servers are deployed on dedicated hosts. For full configuration details please refer to the [ceph-ansible documentation](https://docs.ceph.com/projects/ceph-ansible/en/latest/), and to the group variable definions inside its [official git repository](https://github.com/ceph/ceph-ansible/tree/main/group_vars).

> [!NOTE]
> OneDeploy uses only specific roles from the `ceph-ansible` project and introduces the `opennebula.deploy.ceph` playbook to be executed *before* the main deployment.

```yaml
---
all:
  vars:
    ansible_user: root
    one_version: '6.10'
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
  vars:
    osd_auto_discovery: true

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

In this scenario, Ceph OSD servers are deployed together with the OpenNebula KVM nodes. CPU and RAM resources for OSDs are limited as much as possible, to ensure minimal interference with the running guest VMs.

> [!NOTE]
> The exact amount of CPU and RAM will depend on the size of the specific OSD. To calculate these values please refer to the Ceph documentation.

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebulapass
    one_version: '6.10'
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
    # Assuming all osds are of equal size, setup resource limits and reservations
    # for all osd systemd services.
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
    osd_auto_discovery: true

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

### Journaling Devices

The `one-deploy` and `ceph-ansible` playbooks also allow you to configure journaling devices. The journaling mechanism helps maintain data integrity and consistency, especially in the event of power outages or system failures. Journaling also enables Ceph to achieve better write performance, particularly when using traditional HDDs as primary storage. This is because journaling devices (SSDs) typically have faster write speeds and lower latency compared to HDDs.

To configure journaling devices, simply add the attribute `dedicated_devices` to each device in your `osds` definition:

```yaml
osds:
  vars:
  hosts:
    osd1:
      ansible_host: 10.255.0.1
      dedicated_devices: ['/dev/disk/by-id/nvme-SAMSUNG_MZKLIWJBBLA-00A04_S6VANG0W80392', '/dev/disk/by-id/nvme-SAMSUNG_MZKLIWJBBLA-00A07_S6VANG0W804839']
      devices:
        - /dev/disk/by-id/wwn-0x5000cca2e950aa70
        - ...
```

### CRUSH Maps

The `ceph-ansible` playbooks allow management of CRUSH (Controlled Replication Under Scalable Hashing) maps. The CRUSH algorithm and associated CRUSH map provide a flexible and scalable method for data placement, ensuring fault tolerance, load balancing, and efficient use of storage resources.

Consider the partial inventory below:

```yaml
osds:
  vars:
    # Disable OSD device auto-discovery, as the devices are explicitly specified below (per each OSD node).
    osd_auto_discovery: false
    # Enable CRUSH rule/map management.
    crush_rule_config: true
    create_crush_tree: true
    # Define CRUSH rules.
    crush_rule_hdd:
      name: HDD
      root: root1
      type: host
      class: hdd
      default: false
    crush_rules:
      - "{{ crush_rule_hdd }}"
  hosts:
    osd1:
      ansible_host: 172.20.0.10
      devices:
        - /dev/vdb
        - /dev/vdc
      osd_crush_location: { host: osd1, rack: rack1, root: root1 }
    osd2:
      ansible_host: 172.20.0.11
      devices:
        - /dev/vdb
        - /dev/vdc
      osd_crush_location: { host: osd2, rack: rack2, root: root1 }
    osd3:
      ansible_host: 172.20.0.12
      devices:
        - /dev/vdb
        - /dev/vdc
      osd_crush_location: { host: osd3, rack: rack3, root: root1 }
```

In this case, running the `opennebula.deploy.ceph` playbook should result in such CRUSH architecture:

```shell
# ceph osd crush tree
ID   CLASS  WEIGHT   TYPE NAME
-15         0.37500  root root1
 -9         0.12500      rack rack1
 -3         0.12500          host osd1
  0    hdd  0.06250              osd.0
  3    hdd  0.06250              osd.3
-11         0.12500      rack rack2
 -7         0.12500          host osd2
  1    hdd  0.06250              osd.1
  4    hdd  0.06250              osd.4
-10         0.12500      rack rack3
 -5         0.12500          host osd3
  2    hdd  0.06250              osd.2
  5    hdd  0.06250              osd.5
 -1               0  root default
```

For full details please refer to the official [Ceph CRUSH Map documentation](https://docs.ceph.com/en/quincy/rados/operations/crush-map/).

## Deploying a Local Ceph Cluster

For deploying the Ceph cluster, `one-deploy` includes the `opennebula.deploy.ceph` playbook. You can execute the playbook with this command:

```shell
$ ansible-playbook -i inventory/ceph.yml opennebula.deploy.ceph
```

The one-deploy/inventory directory contains the ceph.yml file, and the ceph-hci.yml file for Hyper-Converged Infrastructure.

Below are the contents of the ceph.yml file. The Ceph configuration begins at ceph:. (For full details on configuring ceph-* roles please refer to the [Ceph Ansible playbook documentation](https://docs.ceph.com/projects/ceph-ansible/en/latest/).

```yaml
---
all:
  vars:
    ansible_user: root
    one_version: '6.10'
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
  vars:
    osd_auto_discovery: true

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

The table below lists some of the parameters, which you should update to your own deployment:

| Parameter      | Description
|----------------|------------------------------------------------------------------------------------------------|
| `one_version`  | The version of OpenNebula to install.                                                          |
| `ansible_user` | The user that will run the Ansible playbook.                                                   |
| `one_pass`     | Password for the OpenNebula user `oneadmin`.                                                   |
| `features`     | Include `ceph: true` to use the Ceph feature in OneDeploy.                                     |
| `ds`           | Set `mode: ceph` to use the Ceph cluster for datastores and images.                            |
| `vn`           | Definition of the OpenNebula virtual network ("`admin_net`") that will be created for the VMs. |
| `PHYDEV`       | The physical interface on the servers that will attach to the virtual to the virtual network.  |
| `AR`           | Address range (first IP and size) to assign to the VMs.                                        |
| `GATEWAY`      | Default gateway for the network.                                                               |
| `DNS`          | DNS server for the network.                                                                    |
| `f1`,`n1`,`n2` | `ansible_host` IP addresses for the Front-end (`f1`) and Hypervisors (`n1` and `n2`).          |

For the full guide on configuring `ceph-*` roles, please refer to the [official Ceph documentation](https://docs.ceph.com/projects/ceph-ansible/en/latest/).

## Running the Ansible Playbook

For complete information on running the playbooks, please see [Using the Playbooks](sys_use).

To run the playbook, follow these basic steps:

1. **Prepare the inventory file**, adapting it to your needs. For example, update the provided `ceph.yml` file to match your infrastructure settings.

2. **Check the connection** between the Ansible control node and the managed nodes. You can verify the network connection, ssh and sudo configuration with the following command:

```shell
ansible -i inventory/local.yml all -m ping -b
```

3. **Run the playbook**, for example from the `one-deploy` directory with the below command:
```shell
ansible-playbook -i inventory/ceph.yml opennebula.deploy.main
```
After execution of the playbook is finished, your new OpenNebula cloud is ready. You can check the installation by following the [Verification guide](sys_verify).
