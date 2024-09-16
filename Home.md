[//]: # ( vim: set wrap : )

# OpenNebula Ansible Playbooks Documentation

OneDeploy, the OpenNebula Ansible project, is a set of playbooks and roles that enable you to deploy an OpenNebula cloud in a simple and convenient way.

The supported automated deployments include advanced features such as Ceph storage, High Availability for the Front-end, federation, and installing the Front-end in a VM.

The documentation is organized in sections according to architecture and installation type. It includes examples of deployments on three reference architectures, progressing from the most simple (based on local storage) to the most complex (Ceph storage). Each section includes concise explanations of the configurations implemented on both the platform and OpenNebula. Reference and examples are also provided for additional configurations such as HA, federation, VXLAN and others.

> [!TIP]
> For installing on the local storage and shared storage reference architectures, the OpenNebula documentation includes two step-by-step [tutorials](https://docs.opennebula.io/stable/installation_and_configuration/automatic_deployment/one_deploy_overview.html).

## Contents

* General Documentation (Common to all Installations):
* [Requirements & Platform Notes](sys_reqs)
* [Release Notes](https://github.com/OpenNebula/one-deploy/releases)
* [Using the Playbooks](sys_use)
* Installing for the Reference Cloud Architectures:
  * [Single Front-end Cloud and Local Storage](arch_single_local)
  * [Single Front-end Cloud and Shared Storage](arch_single_shared)
  * [Single Front-end Cloud and Ceph storage](arch_single_ceph)
* [Verifying the Installation](sys_verify)
* Installing with Advanced Configurations:
  * [Highly-available Front-end](arch_ha)
  * [Federated Front-ends](arch_fed)
  * [VXLAN/EVPN Networking](arch_evpn)
* Additional Installation Options:
  * [Airgapped Installation](sys_airgap)
  * [Front-end Installation as VM](arch_infra)
  * [Connect Through a Bastion Host](arch_bastion)
* Developer Information:
  * [Playbook Reference](sys_reference)
  * [Molecule Testing](test_molecule)
  * [Coding Style](code_style)
