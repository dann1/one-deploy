[//]: # ( vim: set wrap : )

# Coding Style Guide

## 1. Repository Structure

### 1.1 The Collection

The `one-deploy` project has been designed from the start as an **Ansible Collection**, so it's convenient to install it using the `ansible-galaxy` CLI command. Ansible collection structure differs from a classic Ansible project, you can read more about it [here](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_structure.html).

In [#10](https://github.com/OpenNebula/one-deploy/pull/10) we've merged Ceph support. The [ceph-ansible](https://github.com/ceph/ceph-ansible) repository (that we borrow roles from) is not a collection, so the integration had to be done via a git submodule with some awkward `ansible.cfg` setup:

```dosini
[defaults]
collections_paths = ./ansible_collections/
action_plugins    = ./vendor/ceph-ansible/plugins/actions/
callback_plugins  = ./vendor/ceph-ansible/plugins/callback/
filter_plugins    = ./vendor/ceph-ansible/plugins/filter/
roles_path        = ./vendor/ceph-ansible/roles/
library           = ./vendor/ceph-ansible/library/
module_utils      = ./vendor/ceph-ansible/module_utils/
```

> [!IMPORTANT]
> We've made this exception and learned to live with it, but in general we don't want to repeat such mistakes. **Please, make sure one-deploy stays a collection as close to its purest form as possible.**

### 1.2 Roles

There is nothing special about roles implemented in one-deploy. There are few design choices however you should probably know:

- Most of the roles depend on the `opennebula.deploy.common` role, it's the place where you can put some global defaults or pre-generate global facts.
- Some of the roles are divided into parts (sub-roles) that should be executed in dedicated inventory groups.
- Each role contains a readme file written in markdown.

### 1.3 Inventory

Our inventory markup language of choice is YAML, since it's more flexible than the usual INI format. In particular it allows you to express more complex inventories in a neat way, please take a look at the example below. The `vn` object would be much harder to define (and less readable) in an INI based inventory file.

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

node:
  hosts:
    n1b1: { ansible_host: 10.2.50.20 }
    n1b2: { ansible_host: 10.2.50.21 }
```

### 1.4 The Makefile

The Makefile is considered to be optional, please don't rely on it for implementing any of the core functionalities, just don't put them there. :-1:

For example, manual federated deployment requires sequential execution with multiple different inventory files, then the Makefile is not the correct place to implement that, just let the users execute manual steps manually. :point_up::relieved:

### 1.5 Pre-checks

The `opennebula.deploy.precheck` role is executed in the `opennebula.deploy.pre` playbook. The main purpose of this role is to verify various conditions globally on the cluster level and prevent execution of the `opennebula.deploy.site` playbook if the conditions are not met. While implementing new features or updating existing ones you should consider adding new or updating existing pre-checks. Please make sure you design and test `ansible.builtin.assert` logic statements properly, don't rely on intuition, just identify and test all the test cases. :+1:

> [!WARNING]
> The `opennebula.deploy.precheck` role doesn't depend on other roles and doesn't load defaults, it has been a conscious decision to repeat definitions of defaults inside logic statements.

## 2. Making your code readable

### 2.1 Don't get too fancy with booleans

[YAML 1.1](https://yaml.org/type/bool.html) used to support the following boolean values `y Y yes Yes YES n N no No NO true True TRUE false False FALSE on On ON off Off OFF` (sic!), which is ridiculous as somebody could use `on no` to handle all booleans for *off* reason (pun intended).

Luckily [YAML 1.2](https://yaml.org/spec/1.2.2/) properly recognizes `true True TRUE false False FALSE` only.

> [!IMPORTANT]
> Ansible on the other hand still supports multiple variants, but we don't care (not all ideas are good ideas)! Please, always use `true/false` :anger:.

### 2.2 Use "conditional blocks"

Please take a look at the idiom below, this is the way we recommend how to implement complex conditionals. Note, there is no `name:` attribute that we skip on purpose, so the whole expression is similar to a regular *if* statement.

> [!IMPORTANT]
> Please add `name:` attribute to most tasks with the exception of this `when/block` idiom and (if you wish) `include/import` statements.

```yaml
- when: custom_fact == 'custom_value'
  block:
    - name: Task description
      ansible.builtin.set_fact:
        custom_fact: another_custom_value

    - name: Task description
      ansible.builtin.set_fact:
        another_custom_fact: custom_value
```

> [!WARNING]
> A note about `ansible-lint`. The code above fails to validate with `ansible-lint` due to missing `name:` attribute, that's the main reason we don't use `ansible-lint`. Also, `ansible-lint` is annoying to use in general, so we don't care. *We're open for discussing it if you really (x2) think you can change our minds.* :thinking:

### 2.3 Use Jinja2 with task vars

Please take a look at the example task below. You can see that it actually processes multiple JSON payloads, so you can (arguably) consider it to be complex. Now imagine all the code under `vars:` is written as a single line or split into multiple tasks.. :anger:

Dividing Jinja2 pipelines into smaller and named local *vars* (prefixing them with _ is the pattern that we adopted to differentiate them from the actual facts) can make the whole functional expression easier to digest. Also, it allows for inserting comments, so just do it :+1:.

```yaml
- name: Detect or select a Leader
  ansible.builtin.set_fact:
    # If we cannot detect anything, we default to the first host from the current Federation group.
    leader: >-
      {{ federation.groups.frontend[0] if _running is falsy else _leader }}
    # This fact is used to prevent extra/unneeded restart of OpenNebula (triggered via handlers)
    # during initial deployment of a Front-end.
    oned_no_restart: >-
      {{ federation.groups.frontend
         if _running is falsy else
         federation.groups.frontend | difference(_peer_names) }}
  vars:
    # We process shell results from all Front-ends at once.
    _results: >-
      {{ federation.groups.frontend | map('extract', hostvars, ['shell']) | list }}
    _running: >-
      {{ _results | selectattr('failed', 'false') | list }}
    _documents: >-
      {{ _running | map(attribute='stdout') | map('from_json') | list }}
    _server_pools: >-
      {{ _documents | map(attribute='ZONE.SERVER_POOL') | select | list }}
    _peers: >-
      {{ [_server_pools[0].SERVER] | flatten | list }}
    _peer_names: >-
      {{ _peers | map(attribute='NAME') | list }}
    _leader: >-
      {{ (_peers | selectattr('STATE', '==', '3') | first).NAME }}
```

## 3. Always optimize for speed

To speed up Ansible roles we always minimize total number of tasks and loops. If you can achieve something in a single step (no looping, no task splitting, no switch-like statements) with some Jinja2 code (even if it's slightly more complex), just go for it :+1:.

All Jinja2 and Ansible filters are allowed, use them at will. You can also use Python-derived attributes, please take a look at links below.

- [Jinja2 Reference](https://jinja.palletsprojects.com/en/latest/templates/)
- [Ansible Filters](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_filters.html)
- [Python-derived Attributes](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#referencing-key-value-dictionary-variables)

> [!WARNING]
> Please don't add custom filters and modules implemented in Python, filters and attributes mentioned above should be enough for most cases. **Do it only in very specific, well justified cases, otherwise please just don't bother.**

Some examples of what we consider "correct" vs "incorrect" implementations:

**Reduce number of tasks**:

*INCORRECT*:

```yaml
- name: Task description
  ansible.builtin.set_fact:
    custom_fact: "{{ (custom_fact | d([])) + ['<%s>' % item] }}"
  loop: [1, 2, 3, 4, 5]
```

*CORRECT*:

```yaml
- name: Task description
  ansible.builtin.set_fact:
    custom_fact: >-
      {{ _items | map('regex_replace', '^(.*)$', "<\g<1>>") }}
  vars:
    _items: [1, 2, 3, 4, 5]
```

```yaml
- name: Task description
  ansible.builtin.set_fact:
    custom_fact: >-
      {%- set output = [] -%}
      {%- for item in _items -%}
        {{- output.append('<%s>' % item) -}}
      {%- endfor -%}
      {{- output -}}
  vars:
    _items: [1, 2, 3, 4, 5]
```

**Avoid code branching**:

*INCORRECT*:

```yaml
- name: Task description
  ansible.builtin.apt:
    name: [vim, qemu-utils]
    update_cache: true
  when: ansible_os_family == 'Debian'

- name: Task description
  ansible.builtin.yum:
    name: [vim, qemu-img]
    update_cache: true
  when: ansible_os_family == 'RedHat'
```

*CORRECT*:

```yaml
- name: Task description
  ansible.builtin.package:
    name: "{{ _common + _specific[ansible_os_family] }}"
    update_cache: true
  vars:
    _common: [vim]
    _specific:
      Debian: [qemu-utils]
      RedHat: [qemu-img]
```

## 4. Be careful with **run_once**

Since the Federation support has been merged [#38](https://github.com/OpenNebula/one-deploy/pull/38) `run_once` can no longer be used freely in most of the roles (in some special, selected cases only). The reason is the `opennebula` role tries to deploy multiple federated Front-ends in parallel, so the `run_once` has to be *emulated* in multiple subgroups of machines at the same time.

You can read more about how `run_once` works [here](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_strategies.html#running-on-a-single-machine-with-run-once), but it basically picks the first machine from all `play_hosts`.

So, instead of `run_once` you could be using constructions like:

```yaml
- when: inventory_hostname == federation.groups.frontend[0] # instead of `run_once: true`
  block:
    - name: Do the work
      ansible.builtin.set_fact:
        some_result: 123

- name: Use the result somewhere else
  ansible.builtin.set_fact:
    some_result: "{{ hostvars[federation.groups.frontend[0]].some_result }}"
```

## 5. Working with wiki pages

1. Create your personal fork of the one-deploy repository.
2. Add some page inside the wiki section (it can be anything).
3. After 2. you'll be able to clone git repository dedicated for the wiki, like so: `git clone git@github.com:you/one-deploy.wiki.git`.
4. Setup the upstream remote: `git remote add upstream git@github.com:OpenNebula/one-deploy.wiki.git`.
5. Fetch the current documentation from the upstream repository: `git fetch upstream`.
6. Rebase your master branch: `git rebase upstream/master`.
7. Remove commit(s) that are not in upstream: `git reset --hard HEAD~1` (for example).
8. Push master to your wiki fork with force: `git push origin master -f`.
9. Access the wiki in your fork to verify if the procedure worked.

## 6. Testhink (pun intended)

You can find molecule based integration tests inside the one-deploy checkout, they can be basically used to deploy pre-configured environments inside existing OpenNebula instances.

We haven't implemented per role molecule unit tests (yet), but nonetheless feel free to add some container based ones if you think it's properly justified.

**So far testing has been manual labor, you have to actually deploy something to see if your implementation is correct.**
