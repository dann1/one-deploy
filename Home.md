# OpenNebula Ansible Playbooks Documentation

The OpenNebula Ansible project consists of a set of playbooks and roles that let you deploy an OpenNebula cloud in a simple and convenient way.

The documentation is organized based on three distinct architectures. We will start with the most straightforward architecture and gradually move towards more complex scenarios. For each scenario, we will provide concise explanations of the configurations implemented on both the platform and OpenNebula.

## Contents

* [Requirements & Platform Notes](sys_reqs)
* [Release notes](https://github.com/OpenNebula/one-deploy/releases)
* [Using the playbooks](sys_use)
* Deployments
  * [Local storage](arch_single_local)
  * [Shared storage](arch_single_shared)
  * [Ceph storage](arch_single_ceph)
  * [High availability front-ends](arch_ha)
  * [Connect through a bastion host](arch_bastion)
  * [Other configurations](arch_other)
* [Verifying the installation](sys_verify)
* [Playbook reference](sys_reference)
* [Molecule testing](test_molecule)