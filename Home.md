[//]: # ( vim: set wrap : )

# OpenNebula Ansible Playbooks Documentation

The OpenNebula Ansible project consists of a set of playbooks and roles that let you deploy an OpenNebula cloud in a simple and convenient way.

The documentation is organized based on three distinct architectures. We will start with the most straightforward architecture and gradually move towards more complex scenarios. For each scenario, we will provide concise explanations of the configurations implemented on both the platform and OpenNebula.

## Contents

* [Requirements & Platform Notes](sys_reqs)
* [Release notes](https://github.com/OpenNebula/one-deploy/releases)
* [Using the playbooks](sys_use)
* Deployments
  * [Front-end VMs](arch_infra)
  * [Local storage](arch_single_local)
  * [Shared storage](arch_single_shared)
  * [Ceph storage](arch_single_ceph)
  * [Highly-available Front-end](arch_ha)
  * [Federated Front-ends](arch_fed)
  * [VXLAN/EVPN networking](arch_evpn)
  * [Connect through a bastion host](arch_bastion)
* [Verifying the installation](sys_verify)
* [Airgapped installation](sys_airgap)
* [Playbook reference](sys_reference)
* [Molecule testing](test_molecule)
* [Coding style](code_style)
