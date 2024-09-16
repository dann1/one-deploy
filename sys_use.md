[//]: # ( vim: set wrap : )

# Using the Playbooks

To use the playbooks, you'll need to:

1. Download the playbooks.
2. Install the requirements.
3. Create and edit your inventory file.
4. Execute the provisioning.

## Downloading the Playbooks

The easiest and recommended way to use the playbooks is by cloning the [GitHub project](https://github.com/OpenNebula/one-deploy.git).

```shell
$ git clone --recursive https://github.com/OpenNebula/one-deploy.git
```

This will clone the playbooks in the `one-deploy` directory.

> [!NOTE]
> You will need to use this method if you plan to deploy Ceph clusters with OneDeploy.

If you have Ansible already installed, you can also use `ansible-galaxy` to install directly from the GitHub repo:

```shell
$ ansible-galaxy collection install --upgrade git@github.com:OpenNebula/one-deploy.git,release-1.2.0
```

> [!NOTE]
> Although pre-release `0.1.0` was initially pushed to the [Ansible Galaxy community site](https://galaxy.ansible.com/opennebula), this is no longer being maintained. Cloning or installing from the GitHub repo is a much cleaner method, as described in the [Ansible documentation](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html#installing-a-collection-from-a-git-repository).

## Installing the Requirements

To download and install the requirements, you can use Ansible commands or the included Makefile.

**Using the Makefile**: From the `one-deploy` directory, run:

```
make requirements
```

**Using Ansible**: From the `one-deploy` directory, run:

```
ansible-galaxy collection install -r requirements.yml
```

## Executing the Provisioning

At the root of the `one-deploy` directory, the `ansible.cfg` file contains:

```
[defaults]
collections_paths = ./ansible_collections/
```

The `ansible_collections/opennebula/deploy` directory is in fact a symlink to the repo's root directory:

```
one-deploy$ file ansible_collections/opennebula/deploy
ansible_collections/opennebula/deploy: symbolic link to ../../
```

This allows you to use files cloned from git as a "local" Galaxy collection.

You will need to create your inventory file in the `inventory` folder, or alternatively adapt one of the provided files to your needs.

## Creating and Configuring the Inventory File

For your inventory file you can adapt one of the files provided in the `one-deploy/inventory` directory, or create your own.

### Main Inventory File Global Parameters

Below are some of the main parameters for the whole deployment:

| Parameter       | Description                                                                  |
|-----------------|------------------------------------------------------------------------------|
| `one_version`   | OpenNebula version to deploy                                                 |
| `one_pass`      | Password for the `oneadmin` user                                             |
| `ansible_user`  | System user that will run the ansible playbooks (specify if other than root) |


### Example Inventory File

In this example we will create an inventory folder, place the Ansible configuration file and inventory file in it, and execute the playbooks from there.

Create your inventory folder, then navigate to it:

```
mkdir ~/my-one/ && cd ~/my-one/
```

Create the inventory file, in this case `example.yml`:

```
$ cat > example.yml <<'EOF'
---
all:
  vars:
    ansible_user: root
    one_version: '6.10'
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
```

> [!NOTE]
> You will probably need to adapt this sample file to your infrastructure, e.g. IP addresses, etc.

Create the `ansible.cfg` file:

```
$ cat > ansible.cfg <<'EOF'
[defaults]
inventory=./example.yml
gathering=explicit
host_key_checking=false
display_skipped_hosts=true
retry_files_enabled=false
any_errors_fatal=true
stdout_callback=yaml
timeout=30
collections_paths=/home/user/one-deploy/ansible_collections

[ssh_connection]
pipelining=true
ssh_args=-q -o ControlMaster=auto -o ControlPersist=60s
EOF
```

> [!NOTE]
> Ensure to replace `collections_paths` with the path to the Ansible collection.

## Executing the Provisioning

From the `my-one` directory you can run:

```
ansible-playbook -v opennebula.deploy.main
```

You can also execute from the `one-deploy` directory, using the included Makefile or entering `ansible-playbook` commands directly.

```
make I=inventory/my_inventory.yml
```

Or alternatively:

```
ansible-playbook -i inventory/my_inventory.yml opennebula.deploy.main
```

### Executing Only Specific Tasks

You can execute only specific tasks by using tags:

```shell
make I=inventory/my_inventory.yml T=bastion,preinstall
```

Or alternatively:

```shell
$ ansible-playbook -i inventory/example.yml opennebula.deploy.main -t bastion,preinstall
```

For a list of tags please see [below](sys_use#available-tags).

### Customizing the Playbooks

You can also compose your own playbook, or embed `opennebula.deploy.*` roles into an existing automation. For example, to run only SSH key provisioning from the `my-one` directory:

```
ansible-playbook -v keys.yml
```

Where `keys.yml` contains:

```
---
- hosts: frontend:node
  roles:
    - role: opennebula.deploy.helper.key
```

For a complete list of playbooks and roles please refer to the [Playbook Reference](sys_reference).

## Available Tags

| Tag          | Description                                             |
|--------------|---------------------------------------------------------|
| `bastion`    | Render local SSH jump-host configs                      |
| `ceph`       | Manage Ceph on the OpenNebula's side                    |
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
