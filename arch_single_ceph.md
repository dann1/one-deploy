[//]: # ( vim: set wrap : )

# Single Front-end & Ceph Storage

One-deploy uses the official [Ceph playbook for Ansible](https://docs.ceph.com/projects/ceph-ansible/en/latest/) (_ceph-ansible_) for the initial Ceph Cluster configuration, so for a detailed description of all the available attributes and configurations we recommend visiting their official documentation.

From the one-deploy inventory and OpenNebula perspective, a scenario which is a variation of the [shared storage](https://github.com/OpenNebula/one-deploy/wiki/arch_single_shared/) setup is used. Here, the storage for virtual machines (VMs) and the image repository are provided by a local Ceph cluster. Running VMs directly from Ceph storage can enhance the fault tolerance of the system in the event of a host failure, although it comes with the drawback of increased I/O latency.

## Prerequisites

The requirements to be able to run the single deployment Ceph integration are fundamentally the same as the requirements to deploy a Ceph cluster, with some special considerations:

- **Dedicated Servers**: You need dedicated servers to act as **OSDs** (Object Storage Daemons), **MONs** (Monitor Nodes), and **MGRs** (Manager Nodes). The number of nodes depends on your desired redundancy and performance requirements.
- **Disk Storage**: Each OSD node should have one or more disks dedicated to storing data. SSDs are recommended for journaling and metadata purposes, while HDDs or SSDs can be used for actual data storage. **It's mandatory that these disks are formatted and empty**, without any partition created.
- **Network Infrastructure**: A reliable and high-speed network infrastructure is crucial for efficient communication between nodes. This includes both public and cluster networks. You will also need to configure two networks to be used in the Ceph cluster:
    - A private network for a private communication between the nodes of the Cluster.
    - A public network to ensure that each node is accessible from the service network on which OpenNebula operates, **otherwise OpenNebula will not be able to communicate with the Ceph cluster**.

## Configuring the base Intenvory

Below is a representative workflow of how the Ceph Ansible playbook typically works, focusing on components such as OSD (Object Storage Daemons), MON (Monitor Nodes) and MGR (Manager Nodes) that will later be added to OpenNebula, implementing all the functionalities described for the [Ceph Datastore](https://docs.opennebula.io/6.8/open_cluster_deployment/storage_setup/ceph_ds.html) in the OpenNebula documentation.:

1. **Inventory Setup**: The playbook begins by defining the inventory, which includes details of all the servers that will be part of the Ceph cluster. This could include separate groups for OSD nodes, MON nodes, MGR nodes, and any other necessary infrastructure:

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
> For more details about this attributes we recommend to take a look to the [Ceph Ansible playbook documentation](https://docs.ceph.com/projects/ceph-ansible/en/latest/).

2. **Preparation**: Before deploying Ceph, the playbook may perform tasks to ensure that all necessary prerequisites are met on the target servers. This could involve installing required packages, configuring network settings, and ensuring that the servers have adequate resources.

3. **Ceph Components deployment**:
    - MON Deployment: The playbook starts by deploying the MON nodes. MONs are responsible for maintaining cluster membership and state. Ansible will typically install the necessary packages, generate and distribute authentication keys, and configure the MON nodes to communicate with each other.

    - OSD Deployment: Once the MON nodes are up and running, the playbook proceeds to deploy the OSD nodes. OSDs are responsible for storing data in the Ceph cluster. Ansible will partition the disks and configure them to act as OSDs. It will then add the OSD nodes to the cluster and rebalance data across them.

    - MGR Deployment: MGR nodes, or Manager nodes, are responsible for managing and monitoring the Ceph cluster. The playbook will deploy MGR nodes and configure them to collect and present cluster metrics, handle commands and requests from clients, and perform other management tasks.

4. **Cluster Configuration**: With all the necessary components deployed, the playbook will then perform any additional configuration tasks required to finalize the Ceph cluster setup. This could include setting placement groups (PGs), configuring pools, enabling features like erasure coding or cache tiering, and optimizing performance settings. By default, one pool will be created with the name `one`.

## Adding more configuration according to each use case

In order to be able to run the one-deploy playbook including the Ceph Cluster configuration, we need to add additional information to the one-deploy inventory depending on our use case. Please find listed the different use cases and example configurations currently supported by one-deploy.

### Dedicated (Non-HCI)

In this scenario Ceph OSD servers are deployed on dedicated hosts. Please refer to the documentation of the [ceph-ansible](https://docs.ceph.com/projects/ceph-ansible/en/latest/) project and to the group variable definions inside its [official git repository](https://github.com/ceph/ceph-ansible/tree/main/group_vars) for the full guide on how to configure it.

> [!NOTE]
> One-deploy uses only specific roles from the `ceph-ansible` project and introduces the `opennebula.deploy.ceph` playbook to be executed **before** the main deployment.

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

In this scenario we deploy Ceph OSD servers along the OpenNebula KVM nodes. Here, we limit and reserve CPU and RAM for Ceph OSDs to ensure
they interfere with the running guest VMs as lightly as possible.

> [!NOTE]
> The exact amount of CPU and RAM depends on the size of the specific OSD, please refer to the Ceph documentation to calculate these.

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
You can also configure jornaling devices using one-deploy and Ceph Ansible playbooks. The journaling mechanism helps maintain data integrity and consistency, especially in the event of unexpected power outages or system failures. Ceph also can achieve better write performance, particularly when using traditional HDDs as primary storage. This is because journaling devices (SSDs) typically have faster write speeds and lower latency compared to HDDs.

In order to configure journling devices, you just need to add the attribute `dedicated_devices` to each device in your `osds` definition:
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

It is possible to manage CRUSH (Controlled Replication Under Scalable Hashing) map in `ceph-ansible`. The CRUSH algorithm and the associated CRUSH map provide a flexible and scalable method for data placement, ensuring fault tolerance, load balancing, and efficient utilization of storage resources. Please take a look at the partial inventory below:

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

Running the `opennebula.deploy.ceph` playbook should result in such CRUSH architecture:

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

Please refer to the official Ceph [documentation on CRUSH Maps](https://docs.ceph.com/en/quincy/rados/operations/crush-map/).

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

## Running the Ansible Playbooks

**1. Prepare the inventory file**: Update the `ceph.yml` file in the inventory file to match your infrastructure settings. Please be sure to update or review the following variables:
  - `ansible_user`, update it if different from root
  - `one_pass`, change it to the password for the oneadmin account
  - `one_version`, be sure to use the latest stable version here
  - `features.ceph`, to enable Ceph in one-deploy
  - `ds.mode`, to confgure Ceph datastores in OpenNebula

**2. Check the connection**: Verify the network connection, ssh and sudo configuration run the following command:
```shell
ansible -i inventory/ceph.yml all -m ping -b
```
**3. Site installation**: Now we can run the site playbooks that provision a local Ceph cluster install and configure OpenNebula services
```shell
ansible-playbook -i inventory/ceph.yml opennebula.deploy.pre opennebula.deploy.ceph opennebula.deploy.site
```
Once the execution of the playbooks finish your new OpenNebula cloud is ready. [You can now head to the verification guide](sys_verify).
