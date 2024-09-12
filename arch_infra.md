[//]: # ( vim: set wrap : )

# Front-end VMs

OneDeploy allows you to deploy OpenNebula Front-ends on Virtual Machines (VMs) on existing hypervisor hosts, instead of on bare-metal machines. You can pre-create Libvirt VMs on existing hypervisors, then use them to create fully-operational OpenNebula Front-ends (HA). This approach allows for using large bare-metal machines dedicated for hypervisor workloads to also run OpenNebula Front-ends in a safe and standard way, simplifying the overall architecture.

In `one-deploy`, the functionality for bootstrapping Front-end VMs is provided by the `opennebula.deploy.infra` playbook and the `opennebula.deploy.infra` role.

## Pre-requisites

You will need bare-metal hosts with Libvirt software pre-installed. These are the hosts where the OpenNebula Front-ends will be installed as VMs. You must install Libvirt prior to running the deployment. For example, in Ubuntu run `apt install -y libvirt-clients libvirt-daemon-system qemu-kvm` or `apt install opennebula-node-kvm`.

## Populating the Inventory

Taken directly from the `inventory/infra.yml` example:

```yaml
---
all:
  vars:
    ansible_user: root
    ensure_keys_for: [root]
    ensure_hosts: true
    one_pass: opennebula
    one_version: '6.10'
    ds: { mode: ssh }
    vn:
      service:
        managed: true
        template:
          VN_MAD: bridge
          BRIDGE: br0
          AR:
            TYPE: IP4
            IP: 10.2.50.200
            SIZE: 48
          NETWORK_ADDRESS: 10.2.50.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 10.2.50.1
          DNS: 10.2.50.1
    one_vip: 10.2.50.86
    one_vip_cidr: 24
    one_vip_if: eth0

infra:
  vars:
    os_image_url: https://d24fmfybwxpuhu.cloudfront.net/ubuntu2204-6.8.1-1-20240131.qcow2
    os_image_size: 20G
    infra_bridge: br0
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }

frontend:
  vars:
    context:
      ETH0_DNS: 10.2.50.1
      ETH0_GATEWAY: 10.2.50.1
      ETH0_MASK: 255.255.255.0
      ETH0_NETWORK: 10.2.50.0
      ETH0_IP: "{{ ansible_host }}"
      PASSWORD: # PUT YOUR PASSWORD HERE
      SSH_PUBLIC_KEY: |
        ssh-rsa AAA... mopala@opennebula.io
        ssh-rsa AAA... sk4zuzu@gmail.com
  # NOTE: Must use IPv4 addresses for ansible_host vars.
  hosts:
    f1: { ansible_host: 10.2.50.100, infra_hostname: n1a1 }
    f2: { ansible_host: 10.2.50.101, infra_hostname: n1a2 }

node:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
```

### Parameters for the `infra` Inventory Group

The inventory contains this additional section:

```yaml
infra:
  vars:
    os_image_url: https://d24fmfybwxpuhu.cloudfront.net/ubuntu2204-6.8.1-1-20240131.qcow2
    os_image_size: 20G
    infra_bridge: br0
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
```

Note that:

- Members of the `infra` inventory group should be *bare-metal hosts* to install Front-end VMs onto.
- The *bare-metal hosts* should have Libvirt software pre-installed (see [Pre-requisites] above).
- The `os_image_url` variable should point to an official OpenNebula image provided via the [OpenNebula Marketplace](https://marketplace.opennebula.io/appliance) or to some other compatible image that runs [OpenNebula Contextualization](https://github.com/OpenNebula/one-apps/wiki/linux_installation).
- The `os_image_size` is needed for resizing (up) the QCOW2 images for each of the deployed Front-ends; the default is **20G**.
- The `infra_bridge` must be pre-created by the user. OneDeploy will use this bridge device to insert Libvirt's NICs into.

### Setting Context Variables for the Front-end VMs

Another important aspect is providing the context variables for the VMs that will host the Front-ends:

```yaml
frontend:
  vars:
    context:
      ETH0_DNS: 10.2.50.1
      ETH0_GATEWAY: 10.2.50.1
      ETH0_MASK: 255.255.255.0
      ETH0_NETWORK: 10.2.50.0
      ETH0_IP: "{{ ansible_host }}"
      PASSWORD:  # PUT YOUR PASSWORD HERE
      SSH_PUBLIC_KEY: |
        ssh-rsa AAA... mopala@opennebula.io
        ssh-rsa AAA... sk4zuzu@gmail.com
  # NOTE: Must use IPv4 addresses for ansible_host vars.
  hosts:
    f1: { ansible_host: 10.2.50.100, infra_hostname: n1a1 }
    f2: { ansible_host: 10.2.50.101, infra_hostname: n1a2 }
```

- The `context` dictionary above contains the *minimal* set of attributes to make networking operational inside the Front-end VMs.
- The `PASSWORD` context attribute sets the SSH password for the `root` user on the Frontend VM. Specify the desired password or remove the attribute completely in order to disable password-based SSH access for `root`.
- The `infra_hostname` must point to an inventory hostname from the `infra` group. This effectively means that the Front-end VM will be deployed on that *bare-metal (infra) host*.

> [!WARNING]
> The `ansible_host` variable in the example above cannot be a DNS name, it **must** be an IPv4 address. It's used not only to access the Front-ends, but also to reconstruct MAC addresses. The `ETHx_MAC` variable **must** match the MAC defined in Libvirt, which we simply reconstruct like so: `ETH0_MAC='{{ context.ETH0_MAC | d("02:01:%02x:%02x:%02x:%02x" | format(*(context.ETH0_IP.split(".") | map("int")))) }}`.

Lastly, *bare-metal hosts* can be reused as OpenNebula hypervisors:

```yaml
node:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
```

## Deploying

The deployment procedure here isn't much different from the usual one, it requires a single additional step:

1. Run the **infra** playbook first:

   ```shell
   $ make I=inventory/infra.yml infra
   ```

2. Run everything else:

   ```shell
   $ make I=inventory/infra.yml
   ```
