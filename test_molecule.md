# Molecule testing

## Requirements (client)

Molecule and pyone are installed as python/pip dependencies for `one-deploy`:

```shell
~/one-deploy$ cat requirements.txt
netaddr
molecule
pyone>=6.8.0
```

You can install all `one-deploy` requirements using the included Makefile:

```shell
~/one-deploy $ make requirements
```

Or directly:

```shell
~/one-deploy $ pip3 install -r requirements.txt
~/one-deploy $ ansible-galaxy collection install -r requirements.yml
```

## Requirements (server)

To deploy molecule integration environments (`ceph-hci`, `passenger-ha`, ...) you're going to need a working
OpenNebula instance with pre-configured networking and pre-installed OS images and VM templates.

:warning: You can use OpenNebula's [Public Marketplace](https://marketplace.opennebula.io/appliance) to download them.

Download (and rename) VM templates and OS images into your OpenNebula instance:

- `Ubuntu 22.04` -> `ubuntu2204`
- `Ubuntu 20.04` -> `ubuntu2004`
- `AlmaLinux 9` -> `alma9`
- `AlmaLinux 8` -> `alma8`

## Configuration

Create the `.env.yml` file in your one-deploy's checkout root, with the following content (you can use `.env.yml.sample` as a template):

```yaml
ONE_HOST: http://localhost:2633/RPC2
ONE_USER: oneadmin
ONE_PSWD: opennebula
ONE_TOKEN: example:example
ONE_VNET: service
ONE_SUBNET: 172.20.0.0/16
ONE_RANGE1: 172.20.86.100 4
ONE_RANGE2: 172.20.86.104 4
ONE_RANGE3: 172.20.86.108 4
```

- Provide OpenNebula endpoint and credentials.
- Provide your support token (required for the `prometheus-ha` environment).
- Customize VNET name, subnet and IP ranges.

## Converging environments

To list all available environments/tests:

```shell
~/one-deploy $ molecule list
INFO     Running ceph-hci > list
INFO     Running passenger-ha > list
INFO     Running prometheus-ha > list
                   ╷             ╷                  ╷               ╷         ╷
  Instance Name    │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged
╶──────────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
  ceph-hci-f1      │ default     │ ansible          │ ceph-hci      │ false   │ false
  ceph-hci-n1      │ default     │ ansible          │ ceph-hci      │ false   │ false
  ceph-hci-n2      │ default     │ ansible          │ ceph-hci      │ false   │ false
  passenger-ha-f1  │ default     │ ansible          │ passenger-ha  │ false   │ false
  passenger-ha-f2  │ default     │ ansible          │ passenger-ha  │ false   │ false
  passenger-ha-f3  │ default     │ ansible          │ passenger-ha  │ false   │ false
  passenger-ha-f4  │ default     │ ansible          │ passenger-ha  │ false   │ false
  prometheus-ha-f1 │ default     │ ansible          │ prometheus-ha │ false   │ false
  prometheus-ha-f2 │ default     │ ansible          │ prometheus-ha │ false   │ false
  prometheus-ha-f3 │ default     │ ansible          │ prometheus-ha │ false   │ false
  prometheus-ha-f4 │ default     │ ansible          │ prometheus-ha │ false   │ false
```

To deploy the ceph-hci environment:

```shell
~/one-deploy $ molecule converge -s ceph-hci
```

If everything goes well, you should be able to login and examine the environment:

```shell
~/one-deploy $ molecule list -s ceph-hci
INFO     Running ceph-hci > list
                ╷             ╷                  ╷               ╷         ╷
  Instance Name │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged
╶───────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
  ceph-hci-f1   │ default     │ ansible          │ ceph-hci      │ true    │ true
  ceph-hci-n1   │ default     │ ansible          │ ceph-hci      │ true    │ true
  ceph-hci-n2   │ default     │ ansible          │ ceph-hci      │ true    │ true
```

```shell
$ onevm ssh ceph-hci-f1
```

## Destroing environments

To destroy a specific environment:

```shell
~/one-deploy $ molecule destroy -s ceph-hci
```

```shell
~/one-deploy $ molecule list -s ceph-hci
INFO     Running ceph-hci > list
                ╷             ╷                  ╷               ╷         ╷
  Instance Name │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged
╶───────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
  ceph-hci-f1   │ default     │ ansible          │ ceph-hci      │ false   │ false
  ceph-hci-n1   │ default     │ ansible          │ ceph-hci      │ false   │ false
  ceph-hci-n2   │ default     │ ansible          │ ceph-hci      │ false   │ false
```

To destroy all available environments:

```shell
~/one-deploy $ molecule destroy --all
```