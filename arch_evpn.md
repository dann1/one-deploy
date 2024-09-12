[//]: # ( vim: set wrap : )

# VXLAN/EVPN Networking

OpenNebula supports VXLAN-based VNETs in both multicast and EVPN modes. To learn more, please see the documentation at [Using VXLAN with BGP EVPN](https://docs.opennebula.io/stable/open_cluster_deployment/networking_setup/vxlan.html#using-vxlan-with-bgp-evpn).

To establish the BGP/EVPN Control Plane in `one-deploy` we use the [FRR/EVPN](https://docs.frrouting.org/en/latest/evpn.html) routing service.

## Architecture

The hypervisors run FRR routing daemons to send BGP updates with the MAC address and IP (optional) for each VXLAN tunnel endpoint (VTEP). The updates are distributed to all the hypervisors using one or more BGP route reflectors (RR). The following diagram shows the main components of the architecture:


```
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐
│ Front-end (HA)                   │
│ ┌────────┐ ┌────────┐ ┌────────┐ │
│ │        │ │        │ │        │ │
│ │  ON-1  │─│  ON-2  │─│  ON-3  │ │
│ │  RR-1  │ │  RR-2  │ │        │ │
│ │        │ │        │ │        │ │
│ └────────┘ └───┬────┘ └────────┘ │
│                │ VIP 10.2.50.86  │
│       ┌────────┴───────┐         │
│  ┌────┴────┐       ┌───┴─────┐   │
│  │         │       │         │   │
│  │ KVM-01  │       │ KVM-02  │   │
│  │ VTEP-01 │←VXLAN→│ VTEP-02 │   │
│  │         │       │         │   │
│  └─────────┘       └─────────┘   │
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
```

## Ansible Role

Below is a complete sample HA config file:

```yaml
---
all:
  vars:
    ansible_user: ubuntu
    ensure_keys_for: [ubuntu, root]
    one_pass: opennebula
    one_version: '6.8'
    features: { evpn: true }
    ds: { mode: ssh }
    vn:
      evpn0:
        managed: true
        template:
          VN_MAD: vxlan
          VXLAN_MODE: evpn
          IP_LINK_CONF: nolearning=
          PHYDEV: eth0
          AUTOMATIC_VLAN_ID: "YES"
          GUEST_MTU: 1450
          AR:
            TYPE: IP4
            IP: 172.17.2.200
            SIZE: 48
          NETWORK_ADDRESS: 172.17.2.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 172.17.2.1
          DNS: 1.1.1.1
    one_vip: 10.2.50.86
    one_vip_cidr: 24
    one_vip_if: eth0

router:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }

frontend:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
    n1a3: { ansible_host: 10.2.50.12 }

node:
  hosts:
    n1b1: { ansible_host: 10.2.50.20 }
    n1b2: { ansible_host: 10.2.50.21 }
```

> [!WARNING]
> OneDeploy currently does not support the `evpn` feature for Federated Front-ends deployed through with the **parallel** deployment type.

To enable the `evpn` feature, you will need to adjust the `features` dictionary and define the `router` inventory group. Machines defined in the `router` group will be basically configured as BGP Route Reflectors:

```yaml
all:
  vars:
    features: { evpn: true }

router:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
```

> [!NOTE]
> If you don't define the `router` group, then you can manually set the `evpn_rr_servers = [1.2.3.4, 2.3.4.5]` variable and reuse preexisting Route Reflectors (unmanaged by OneDeploy).

> [!WARNING]
> If your `frontend` and `node` groups share some machines, then please do **not** add these machines to the `router` group. BGP configuration of Route Reflectors and VTEP nodes differs significantly and is difficult to merge; for simplicity this is not supported.

Enabling the `evpn` feature makes sense only if you use VXLAN VNETs in OpenNebula, as in the example below:

```yaml
all:
  vars:
    vn:
      evpn0:
        managed: true
        template:
          VN_MAD: vxlan
          VXLAN_MODE: evpn
          IP_LINK_CONF: nolearning=
          PHYDEV: eth0
          AUTOMATIC_VLAN_ID: "YES"
          GUEST_MTU: 1450
          AR:
            TYPE: IP4
            IP: 172.17.2.200
            SIZE: 48
          NETWORK_ADDRESS: 172.17.2.0
          NETWORK_MASK: 255.255.255.0
          GATEWAY: 172.17.2.1
          DNS: 1.1.1.1
```

> [!IMPORTANT]
> The attribute `VXLAN_MODE: evpn` **must** be present in the VNET definition (otherwise there would be no point in enabling the `evpn` feature). Using the attribute `IP_LINK_CONF: nolearning=` is recommended.
> Attribute `VXLAN_MODE: evpn` (`IP_LINK_CONF: nolearning=` is recommended) **must** be used in the VNET definition, otherwise there is no point in enabling the `evpn` feature whatsoever.

> [!WARNING]
> Because the VXLAN protocol header uses some space in each UDP packet, you should decrease the MTU (`1450` is the usual value) in your VXLAN VNET definitions to accommodate.

After providing the above configurations you can provision your environment as usual:

```shell
$ make I=inventory/evpn0.yml
```
