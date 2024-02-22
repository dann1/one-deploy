[//]: # ( vim: set wrap : )

# Front-end VMs

Instead of deploying OpenNebula Front-ends on bare metal machines directly, it is possible in one-deploy to first pre-create Libvirt VMs in the existing hypervisors and only then use them to create fully-operational OpenNebula Front-ends (HA).

This approach allows for reusing large bare metal machines dedicated for hypervisor workloads to also run OpenNebula Front-ends in a safe and standard way (simplifying the overal architecture).

> [!NOTE]
> One-deploy ships with both `opennebula.deploy.infra` playbook and `opennebula.deploy.infra` role designed to *bootstrap* Front-end VMs.

## Inventory

Taken directly from the `inventory/infra.yml` example:

```yaml
---
all:
  vars:
    ansible_user: root
    ensure_keys_for: [root]
    ensure_hosts: true
    one_pass: opennebula
    one_version: '6.8'
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
      PASSWORD: opennebula
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

You can see this additional section in the inventory:

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

- Members of the **infra** inventory group should be *bare metal hosts* to install Front-end VMs onto.
- The *bare metal hosts* should have Libvirt software pre-installed (for example `apt install -y libvirt-clients libvirt-daemon-system qemu-kvm` or `apt install opennebula-node-kvm` in Ubuntu). This step is left to the user.
- The `os_image_url` variable should point to an official OpenNebula image provided via the [OpenNebula Marketplace](https://marketplace.opennebula.io/appliance) or to some other compatible image that runs [OpenNebula Contextualization](https://github.com/OpenNebula/one-apps/wiki/linux_installation).
- The `os_image_size` is needed for resizing (up) the QCOW2 images for each of the deployed Front-ends, *20G* is the default.
- The `infra_bridge` is left to be pre-created by the user. One-deploy uses this bridge device to insert Libvirt's NICs into.

Another important thing is definition of the context variables for the Front-end VMs:

```yaml
frontend:
  vars:
    context:
      ETH0_DNS: 10.2.50.1
      ETH0_GATEWAY: 10.2.50.1
      ETH0_MASK: 255.255.255.0
      ETH0_NETWORK: 10.2.50.0
      ETH0_IP: "{{ ansible_host }}"
      PASSWORD: opennebula
      SSH_PUBLIC_KEY: |
        ssh-rsa AAA... mopala@opennebula.io
        ssh-rsa AAA... sk4zuzu@gmail.com
  # NOTE: Must use IPv4 addresses for ansible_host vars.
  hosts:
    f1: { ansible_host: 10.2.50.100, infra_hostname: n1a1 }
    f2: { ansible_host: 10.2.50.101, infra_hostname: n1a2 }
```

- The `context` dictionary above contains *minimal* set of attributes to make networking operational inside the Front-end VMs.
- The `infra_hostname` must point to an inventory hostname from the **infra** group, this effectively means that the Front-end VM will be deployed on that *bare metal (infra) host*.

> [!WARNING]
> The `ansible_host` variable in the example above cannot be a DNS name, it **must** be an IPv4 address. It's used not only to access the Front-ends, but also to reconstruct MAC addresses. The `ETHx_MAC` variable **must** match the MAC defined in Libvirt and we simply reconstruct it like `ETH0_MAC='{{ context.ETH0_MAC | d("02:01:%02x:%02x:%02x:%02x" | format(*(context.ETH0_IP.split(".") | map("int")))) }}`.

And finally *bare metal hosts* can be reused as OpenNebula hypervisors:

```yaml
node:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
```

## Deployment

The deployment procedure here isn't much different from the usual one, it requires a single additional step:

1. Run the **infra** playbook first:

   ```shell
   $ make I=inventory/infra.yml infra
   ```

2. Run everything else:

   ```shell
   $ make I=inventory/infra.yml
   ```
