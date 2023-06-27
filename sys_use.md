# Using the Playbooks

## GitHub Project

The easiest way to use the playbooks is by cloning the [GitHub project](https://github.com/OpenNebula/one-deploy.git).

```shell
$ git clone https://github.com/OpenNebula/one-deploy.git
```

If you look closely at the `ansible.cfg` file in the root of the `one-deploy` repository and the directory structure you'll notice:

```dosini
[defaults]
collections_paths=./ansible_collections/
```

```shell
$ stat ./ansible_collections/opennebula/deploy
  File: ./ansible_collections/opennebula/deploy -> ../../
  Size: 6         	Blocks: 0          IO Block: 4096   symbolic link
```

:warning: **Note:** That effectively allows you to use files cloned from git as a "local" galaxy collection.

You can either use included Makefile or enter ansible-playbook commands directly.

To use this repo:

1. Download requirements:

```shell
$ make requirements
```
OR
```shell
$ ansible-galaxy collection install -r requirements.yml
```

2. Create your inventory file inside the `inventory/` folder.

3. Execute the provisioning:

```shell
$ make I=inventory/example.yml
```
OR
```shell
$ ansible-playbook -i inventory/example.yml opennebula.deploy.main
```

4. Execute provisioning for specific tags:

```shell
$ make I=inventory/example.yml T=bastion,preinstall
```
OR
```shell
$ ansible-playbook -i inventory/example.yml opennebula.deploy.main -t bastion,preinstall
```

5. Proceed normally like with any other Ansible playbook. Thank you! :hugs: 

## Ansible Galaxy Collection

For more advance users, the playbooks are available as part of the [Ansible Galaxy community site](https://galaxy.ansible.com/opennebula/cloud), just take a look at the documentation of each role in the OpenNebula collection to include them in your own playbooks.

To install the `opennebula.deploy` collection directly from [Ansible Galaxy](https://galaxy.ansible.com/opennebula) execute:

```shell
$ ansible-galaxy collection install --upgrade opennebula.deploy
```

To deploy a full OpenNebula environment using playbooks downloaded together with the collection:

1. Create your inventory folder:

```shell
$ mkdir ~/my-one/

$ cat > ~/my-one/example.yml <<'EOF'
---
all:
  vars:
    ansible_user: root
    one_version: '6.6'
    one_pass: opennebulapass
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
EOF

$ cat > ~/my-one/ansible.cfg <<'EOF'
[defaults]
inventory=./example.yml
gathering=explicit
host_key_checking=false
display_skipped_hosts=true
retry_files_enabled=false
any_errors_fatal=true
stdout_callback=yaml
timeout=30

[ssh_connection]
pipelining=true
ssh_args=-q -o ControlMaster=auto -o ControlPersist=60s
EOF
```
2. Execute the main playbook:

```shell
$ (cd ~/my-one/ && ansible-playbook -v opennebula.deploy.main)
```

3. You can also compose your own playbook or embed `opennenebula.deploy.*` roles into some existing automation. To for example run only SSH key provisioning, execute:

```shell
$ cat > keys.yml <<'EOF'
---
- hosts: frontend:node
  roles:
    - role: opennebula.deploy.helper.keys
EOF

$ (cd ~/my-one/ && ansible-playbook -v keys.yml)
```

## Available tags

| Tag          | Description                                             |
|--------------|---------------------------------------------------------|
| `bastion`    | Render local SSH jump-host configs                      |
| `datastore`  | Manage datastores                                       |
| `flow`       | Manage the OneFlow service                              |
| `frontend`   | Run all tasks needed for Front-end deployment           |
| `gate`       | Manage OneGate Server and Proxy services                |
| `grafana`    | Manage Grafana                                          |
| `gui`        | Manage Sunstone and FireEdge services                   |
| `keys`       | Generate and provision SSH keys (password-less login)   |
| `libvirt`    | Apply various Libvirt-related fixes on OpenNebula Nodes |
| `network`    | Manage networking                                       |
| `node`       | Run all tasks needed for Node deployment                |
| `preinstall` | Download and install (only) all software packages       |
| `prometheus` | Manage Prometheus Server and exporters                  |
