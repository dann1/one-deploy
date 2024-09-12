[//]: # ( vim: set nowrap : )

# Playbook reference

## Playbooks

| Name / Link | Description |
|-------------|-------------|
| `opennebula.deploy.ceph`  [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/playbooks/ceph.yml)  | Pre-deploys Ceph clusters with [ceph-ansible](https://github.com/ceph/ceph-ansible). |
| `opennebula.deploy.infra` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/playbooks/infra.yml) | Pre-deploys Front-ends as VMs **directly** in Libvirt.                               |
| `opennebula.deploy.main`  [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/playbooks/main.yml)  | Combines `opennebula.deploy.pre` and `opennebula.deploy.site` playbooks.             |
| `opennebula.deploy.pre`   [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/playbooks/pre.yml)   | Runs pre-checks and some operations that are not part of the main deployment.        |
| `opennebula.deploy.site`  [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/playbooks/site.yml)  | Runs the actual deployment.                                                          |

## Roles

| Name / Link | Description |
|-------------|-------------|
| `opennebula.deploy.bastion` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/bastion/README.md) | A role that renders local SSH configs (in the inventory dir), which then can be used to access cluster nodes via an SSH jump host (a.k.a. bastion). |
| `opennebula.deploy.ceph.frontend` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/ceph/frontend/README.md) | A role that manages Ceph-related settings on an OpenNebula Front-end. |
| `opennebula.deploy.ceph.node` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/ceph/node/README.md) | A role that manages Ceph-related settings on an OpenNebula Node. |
| `opennebula.deploy.ceph.repository` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/ceph/repository/README.md) | A role that prepares the Ceph repository. |
| `opennebula.deploy.common` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/common/README.md) | A basic role that aggregates global defaults/handlers, etc. |
| `opennebula.deploy.database` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/database/README.md) | A role that performs initial configuration of the OpenNebula database. |
| `opennebula.deploy.datastore.frontend` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/datastore/frontend/README.md) | A role that manages OpenNebula datastores (to be run on Front-ends). |
| `opennebula.deploy.datastore.generic` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/datastore/generic/README.md) | A role that manages OpenNebula datastores (`generic` mode). |
| `opennebula.deploy.datastore.node` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/datastore/node/README.md) | A role that manages OpenNebula datastores (to be run on Nodes). |
| `opennebula.deploy.datastore.simple` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/datastore/simple/README.md) | A role that manages OpenNebula datastores (`ssh`, `ceph` and `shared` modes). |
| `opennebula.deploy.flow` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/flow/README.md) | A role that manages the OneFlow service. |
| `opennebula.deploy.frr.common` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/frr/common/README.md) | A role that installs Free Range Routing (FRR) software. |
| `opennebula.deploy.frr.evpn` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/frr/evpn/README.md) | A role that configures BGP/EVPN Control Plane (for VXLAN VNETs). |
| `opennebula.deploy.gate` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/gate/README.md) | A role that manages the OneGate service. |
| `opennebula.deploy.gui` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/gui/README.md) | A role that manages Sunstone and FireEdge services. |
| `opennebula.deploy.helper.cache` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/cache/README.md) | A role that updates the APT / DNF cache. |
| `opennebula.deploy.helper.facts` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/facts/README.md) | A role that replaces/optimizes built-in fact gathering. |
| `opennebula.deploy.helper.flush` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/flush/README.md) | A simple role that flushes Ansible handlers. |
| `opennebula.deploy.helper.fstab` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/fstab/README.md) | A role that populates `/etc/fstab` and mounts filesystems. |
| `opennebula.deploy.helper.hosts` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/hosts/README.md) | A role that populates `/etc/hosts` and sets the hostname. |
| `opennebula.deploy.helper.keys` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/keys/README.md) | A role that generates and distributes SSH/RSA keypairs across OpenNebula inventory (password-less login). |
| `opennebula.deploy.helper.python3` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/helper/python3/README.md) | A simple role that installs Python3 on Debian/RedHat-like distros (via BASH script). |
| `opennebula.deploy.infra` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/infra/README.md) | A role that pre-deploys Front-end VMs directly in Libvirt. |
| `opennebula.deploy.kvm` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/kvm/README.md) | A role that manages OpenNebula KVM Nodes/Hosts. |
| `opennebula.deploy.network.common` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/network/common/README.md) | A role that aggregates common network defaults/handlers/tasks etc. |
| `opennebula.deploy.network.frontend` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/network/frontend/README.md) | A role that manages OpenNebula virtual networks (to be run on Front-ends). |
| `opennebula.deploy.network.node` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/network/node/README.md) | A role that manages OpenNebula virtual networks (to be run on Nodes). |
| `opennebula.deploy.opennebula.common` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/opennebula/common/README.md) | A role that aggregates common OpenNebula defaults/handlers etc. |
| `opennebula.deploy.opennebula.leader` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/opennebula/leader/README.md) | A role that detects the Leader. |
| `opennebula.deploy.opennebula.server` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/opennebula/server/README.md) | A role that deploys OpenNebula Front-ends in HA mode. |
| `opennebula.deploy.precheck` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/precheck/README.md) | A role that performs various checks and assertions. |
| `opennebula.deploy.prometheus.common` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/prometheus/common/README.md) | A role that aggregates Prometheus/Grafana defaults/handlers etc. |
| `opennebula.deploy.prometheus.exporter` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/prometheus/exporter/README.md) | A role that manages the Prometheus exporters. |
| `opennebula.deploy.prometheus.grafana` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/prometheus/grafana/README.md) | A role that manages the Grafana service. |
| `opennebula.deploy.prometheus.server` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/prometheus/server/README.md) | A role that manages the Prometheus and Alertmanager services. |
| `opennebula.deploy.repository` [&#x1F517;](https://github.com/OpenNebula/one-deploy/blob/master/roles/repository/README.md) | A role that creates various package repository configs on Debian/RedHat-like distros. |
