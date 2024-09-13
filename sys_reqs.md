[//]: # ( vim: set wrap : )

# Platform Notes

The playbooks have been tested and verified on the following systems:

| Platform               | Notes                    |
| ---------------------- | ------------------------ |
| Ubuntu 22.04, 24.04    | Netplan version >= 0.105 |
| RHEL 9 and derivatives | NetworkManager required  |

# Requirements

* Ansible version >= 2.14 and < 2.16 (currently required if you want to run Ceph provisioning)
* SSH access to the inventory servers, either directly or through a bastion host
* User used to connect to the servers can sudo into root

It's possible to pre-install all requirements in a python virtualenv through use of [poetry](https://python-poetry.org/). For example in Ubuntu 22.04 you can try these steps:

1. `apt install python3-pip`
2. `pip3 install poetry`
3. `git clone https://github.com/OpenNebula/one-deploy.git`
4. `cd ./one-deploy/ && make requirements`

Then you can use poetry to inspect and use the virtual environment, for example:

```shell
~/one-deploy$ poetry env list
one-deploy-zyWWq5iB-py3.11 (Activated)
~/one-deploy$ poetry shell
Spawning shell within /home/user/.cache/pypoetry/virtualenvs/one-deploy-zyWWq5iB-py3.11
~/one-deploy$ . /home/user/.cache/pypoetry/virtualenvs/one-deploy-zyWWq5iB-py3.11/bin/activate
(one-deploy-py3.11) ~/one-deploy$
```

If you don't want to use poetry and virtualenvs, then you can pre-install everything in a classic way (again for Ubuntu 22.04):

1. `apt install python3-pip`
2. `pip3 install 'ansible-core<2.16'`
3. `git clone git@github.com:OpenNebula/one-deploy.git`
4. `cd ./one-deploy/ && make requirements` or `cd ./one-deploy/ && make requirements POETRY_BIN=` (if you want to make sure poetry is not used when it is available anyway).
