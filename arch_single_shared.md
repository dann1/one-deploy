[//]: # ( vim: set wrap : )

# Single Front-end & Shared Storage

This scenario is a variation of the [local storage](arch_single_local) setup. Here, the storage for virtual machines (VMs) and the image repository are provided by an NFS/NAS server. Running VMs directly from shared storage can enhance the fault tolerance of the system in the event of a host failure, albeit with the drawback of increased I/O latency.

<p align="center">
<img src="images/arch_shared.png" width="60%">
</p>

> [!NOTE]
> The playbook assumes that you have already a working NFS server available in your cloud.

## Storage

### NFS server configuration

The NFS/NAS server is configured to export the datastore folders to the hosts in the OpenNebula cloud. In this example we assume that the following structure is created in the NFS/NAS sever:

```
root@nfs-server:/# ls -ln /storage
total 0
drwxr-xr-x 2 9869 9869 6 Jun 26 17:55 one_datastores
```

> [!IMPORTANT]
> The ownership of the folders **MUST** be 9869 as this is the UID/GID assigned to the `oneadmin` account during the installation.

This folder is exported to the OpenNebula servers, for example:

```shell
# /etc/exports
#
# See exports(5) for more information.
#
# Use exportfs -r to reread
# /export	192.168.1.10(rw,no_root_squash)
/storage/one_datastores 172.20.0.0/24(rw,soft,intr,async)
```

### Inventory

The following snippet shows the configuration required to use the `shared` storage using the above NFS share (assuming the NFS server is at 172.20.0.1):

```yaml
    ds: { mode: shared }

    fstab:
      - src: "172.20.0.1:/storage/one_datastores"
```

By default the share is mounted in `/var/lib/one/datastores/`, but this behavior can be changed so any type of `/etc/fstab` entry should be possible to configure; see additional examples below.

## Networking

To [configure the network you can follow the local storage scenario section.](arch_single_local#networking)

## OpenNebula Front-end & Services

To [configure the front-end services](arch_single_local#opennebula-front-end--services) or using your [enterprise edition token](arch_single_local#enterprise-edition) you can follow the local storage scenario sections.

## The complete inventory file

The following file show the complete settings to install a single Front-end with two Hosts using shared storage:

```yaml
---
all:
  vars:
    ansible_user: root
    one_version: '6.10'
    one_pass: opennebulapass

    vn:
      service:
        managed: true
        template:
          VN_MAD: bridge
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 172.20.0.100
            SIZE: 48
          NETWORK_ADDRESS: 172.20.0.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 172.20.0.1
          DNS: 1.1.1.1

    ds: { mode: shared }

    fstab:
      - src: "172.20.0.1:/storage/one_datastores"

frontend:
  hosts:
    f1: { ansible_host: 172.20.0.6 }

node:
  hosts:
    n1: { ansible_host: 172.20.0.7 }
    n2: { ansible_host: 172.20.0.8 }
```

## Running the Ansible Playbook

* **1. Prepare the inventory file**: Update the `shared.yml` file in the inventory file to match your infrastructure settings. Please be sure to update or review the following variables:
  - `ansible_user`, update it if different from root
  - `one_pass`, change it to the password for the `oneadmin` account
  - `one_version`, be sure to use the latest stable version here

* **2. Check the connection**: Verify the network connection, ssh and sudo configuration run the following command:
```shell
ansible -i inventory/shared.yml all -m ping -b
```
* **3. Site installation**: Now we can run the site playbook that install and configure OpenNebula services
```shell
ansible-playbook -i inventory/shared.yml opennebula.deploy.main
```
After execution of the playbook is finished, your new OpenNebula cloud is ready. [You can now head to the verification guide](sys_verify).

## Additional NFS Configuration Options

The playbooks support the setup of any type of `fstab` entry, and include helpers to automatically link NFS folders to datastore folders. For example, you can use multiple NFS servers for different datastores:

```yaml
    ds:
      mode: shared
      config:
        mounts:
          - type: system
            path: /mnt_nfs1/0
          - type: image
            path: /mnt_nfs2/1
          - type: file
            path: /mnt_nfs1/2

    fstab:
      - src: "10.2.50.1:/shared_one"
        path: /mnt_nfs1
        fstype: nfs
        opts: rw,soft,intr,rsize=32768,wsize=32768

      - src: "10.2.50.33:/shared_one"
        path: /mnt_nfs2
        fstype: nfs
        opts: rw,soft,intr,rsize=32768,wsize=32768
```

**After running the playbook** you will see the following set up in the hosts:
```
root@ubuntu2204-18:~# ls -l /var/lib/one/datastores/
total 0
lrwxrwxrwx 1 root root 7 Jun 27 11:10 0 -> /mnt_nfs1/0/
lrwxrwxrwx 1 root root 7 Jun 27 11:10 1 -> /mnt_nfs2/1/
```
> [!NOTE]
> File (`/mnt/nfs_1/2`) will only be symlinked in the front-end

It's also perfectly viable to define different `fstab` lists for each distinct inventory hostname, group or subgroup:

```yaml
frontend:
  vars:
    fstab:
      - src: "10.2.50.1:/var/lib/one/datastores"
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
```
