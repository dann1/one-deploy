# Highly-available Front-end

The `opennebula/server` role is capable of managing multiple, clustered OpenNebula Front-end machines. Each such machine is simply added to the built-in **Zone 0** of OpenNebula.

```
root@n1a1:~# onezone show 0
ZONE 0 INFORMATION
ID                : 0
NAME              : OpenNebula
STATE             : ENABLED


ZONE SERVERS
ID NAME            ENDPOINT
 0 n1a1            http://n1a1:2633/RPC2
 1 n1a2            http://n1a2:2633/RPC2
 2 n1a3            http://n1a3:2633/RPC2

HA & FEDERATION SYNC STATUS
ID NAME            STATE      TERM       INDEX      COMMIT     VOTE  FED_INDEX
 0 n1a1            leader     1          263        263        0     -1
 1 n1a2            follower   1          263        263        0     -1
 2 n1a3            follower   1          263        263        0     -1

ZONE TEMPLATE
ENDPOINT="http://localhost:2633/RPC2
```

## Deployment

To deploy a cluster, it's enough to provide VIP configuration and multiple Front-end machines in the inventory file:

```yaml
all:
  vars:
    one_vip: 10.2.50.86
    one_vip_cidr: 24
    one_vip_if: eth0
```

```yaml
frontend:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
    n1a3: { ansible_host: 10.2.50.12 }
```

:warning: **Note**: All `one_vip*` parameters are strictly required for HA mode to work, i.e. inside the **Leader** Front-end you will **always** find:

```
root@n1a1:~# ip address show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.2.50.10/24 brd 10.2.50.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 10.2.50.86/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
```

## Scaling

If you would like to deploy only a single Front-end, but still make it HA-ready, you can specify the `force_ha` parameter.

```yaml
all:
  vars:
    force_ha: true
```

```yaml
frontend:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
```

Then later, when you decide you want true HA, you can simply increase the number of Front-end machines and re-run the automation:

```yaml
frontend:
  hosts:
    n1a1: { ansible_host: 10.2.50.10 }
    n1a2: { ansible_host: 10.2.50.11 }
    n1a3: { ansible_host: 10.2.50.12 }
```

:warning: **Note**: Conversion from non-HA to HA is not implemented in this automation, please plan ahead!

:warning: **Note**: We support scaling **UP** only, as the reverse operation seems to be uncommon (you can still do it manually!).


