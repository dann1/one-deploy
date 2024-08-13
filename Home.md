[//]: # ( vim: set wrap : )

# OpenNebula Ansible Playbooks Documentation

The OpenNebula Ansible project consists of a set of playbooks and roles that let you deploy an OpenNebula cloud in a simple and convenient way.

The documentation is organized based on three distinct architectures. We will start with the most straightforward architecture and gradually move towards more complex scenarios. For each scenario, we will provide concise explanations of the configurations implemented on both the platform and OpenNebula.

## Contents

* [Requirements & Platform Notes](sys_reqs)
* [Release notes](https://github.com/OpenNebula/one-deploy/releases)
* [Using the playbooks](sys_use)
* Reference Architecture Cloud Deployments
  * [Single front-end cloud based on local storage](arch_single_local)
  * [Single front-end cloud based on shared storage](arch_single_shared)
  * [Single front-end cloud based on Ceph storage](arch_single_ceph)
* [Verifying the installation](sys_verify)
* Advance Configurations
  * [Highly-available Front-end](arch_ha)
  * [Federated Front-ends](arch_fed)
  * [VXLAN/EVPN networking](arch_evpn)
* Additional Installation Options
  * [Airgapped installation](sys_airgap)
  * [Front-end installation as VM](arch_infra)
  * [Connect through a bastion host](arch_bastion)
* Developer Information
  * [Playbook reference](sys_reference)
  * [Molecule testing](test_molecule)
  * [Coding style](code_style)
