[//]: # ( vim: set wrap : )

# Suntone Installation

Since [OpenNebula 6.10](https://docs.opennebula.io/6.10/intro_release_notes/release_notes/whats_new.html#whats-new-in-version), the new Sunstone server is now served by [FireEdge](https://docs.opennebula.io/stable/installation_and_configuration/opennebula_services/fireedge.html#fireedge-conf).

When installing OpenNebula with one-deploy, FireEdge will be automatically installed on its dedicated nodejs server. You can also deploy FireEdge behind a reverse proxy with SSL termination. You can choose to do so with apache or nginx.

For more information about FireEdge deployment, please see the [documentation](https://docs.opennebula.io/stable/installation_and_configuration/large-scale_deployment/fireedge_for_large_deployments.html).


## Basic Installation

There is nothing special required. A very simple inventory will result in FireEdge running on `http://frontend_node:2616`

```yaml
---
all:
  vars:
    ansible_user: root
    one_version: '6.10'
    one_pass: opennebula
    unattend_disable: true
    ds:
      mode: ssh
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
    f1: { ansible_host: 172.20.0.4 }

node:
  hosts:
    n1: { ansible_host: 172.20.0.4 }

```

## SSL Proxy

To add SSL termination, you must define the `ssl` variable

```yaml
frontend:
  hosts:
    f1: { ansible_host: 172.20.0.4 }
  vars:
    one_fqdn: nebula.example.io # name of the web server
    ssl:
      web_server: nginx # can be apache
      key: /etc/ssl/private/ssl-cert-snakeoil.key # must exist previously on the ansible_host
      certchain: /etc/ssl/certs/ssl-cert-snakeoil.pem # must exist previously on the ansible_host
```

This will install nginx or apache on the frontend node and configure it as a reverse proxy with SSL encryption, listening on port 443, for the FireEdge server provided by OpenNebula. The SSL certificates used must exist previously on the frontend host, otherwise apache and nginx will fail to start.
