[//]: # ( vim: set wrap : )

# Platform Notes

The playbooks have been tested and verified on the following systems:

| Platform               | Notes                    |
| ---------------------- | ------------------------ |
| Ubuntu 22.04, 24.04    | Netplan version >= 0.105 |
| RHEL 9 and derivatives | NetworkManager required  |

## Requirements

* Ansible version >= 2.14 and < 2.16 (currently required if you want to run Ceph provisioning)
* SSH access to the inventory servers, either directly or through a bastion host
* The user that will perform the installation needs to sudo to root

## Installing the Requirements
There are essentially two installation methods:

* Method 1: Install in a Python virtual environment, using [poetry](https://python-poetry.org/)
* Method 2: Pre-install Ansible system-wide

Below is a brief description of each method. For details on installation and running the playbooks, see [Using the Playbooks](sys_use).

### For both methods: Clone the `one-deploy` git repo

To clone the `one-deploy` repo, run:

```
git clone https://github.com/OpenNebula/one-deploy.git
```

This will clone to directory `one-deploy`.

Then, proceed to install the requirements using your preferred method below:

### Method 1: Install in a Python virtual environment using poetry

**Install poetry**:

| Ubuntu 22.04                              | Ubuntu 24.04                 |
|-------------------------------------------|------------------------------|
| `apt install python3-pip python3-poetry`  | `apt install python3-poetry` |

Go to the `one-deploy` root directory and install the requirements:

```
cd ./one-deploy/ && make requirements
```

This installs the virtual environment with all requirements. To list the new virtual environment, run:
```
poetry env list
```

Spawn a shell in the virtual environment:
```
poetry shell
```

After switching to the virtual environment, your terminal prompt should begin with the string `(one-deploy-py<version>)`, e.g. `(one-deploy-py3.12)` as shown below:

```
~/one-deploy$ poetry shell
Spawning shell within /home/user/.cache/pypoetry/virtualenvs/one-deploy-Yw-1D8Id-py3.12
~/one-deploy$ . /home/basedeployer/.cache/pypoetry/virtualenvs/one-deploy-Yw-1D8Id-py3.12/bin/activate
(one-deploy-py3.12) front-end:~/one-deploy$
```

### Method 2: Pre-install Ansible system-wide

**Install Python PIP and Ansible**:

| Ubuntu 22.04                              | Ubuntu 24.04                 |
|-------------------------------------------|------------------------------------|
| Run these commands:                       | Run these commands:                |
| `apt install python3-pip`                 | `apt install pipx`                 |
| `pip3 install 'ansible-core<2.16'`        | `pipx install 'ansible-core<2.16'` |

Build the `one-deploy` requirements:
```
cd /path/to/one-deploy/
make requirements
```

> [!TIP]
> If you want to ensure poetry is not used even if it’s available on the system, for building the requirements run `make requirements POETRY_BIN=`.

