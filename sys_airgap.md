[//]: # ( vim: set wrap : )

# Airgapped installation

Currently, `one-deploy` does not provide a dedicated way to do airgapped installations.

However, since release 1.1.1 it should be possible to configure/override the APT/DNF repositories used by `one-deploy`. If all machines where OpenNebula will be deployed use mirrored repositories for their DEB/RPM packages, then airgapped installation should be possible.

The five APT/DNF repositories used by `one-deploy` are:

- [Ceph Community](https://download.ceph.com/)
- [Free Range Routing (DEB)](https://deb.frrouting.org/) / [Free Range Routing (RPM)](https://rpm.frrouting.org/)
- [Grafana (DEB)](https://apt.grafana.com/) / [Grafana (RPM)](https://rpm.grafana.com/)
- [OpenNebula (CE)](https://downloads.opennebula.io/repo/) / [OpenNebula (EE)](https://enterprise.opennebula.io/repo/)
- [Passenger (DEB)](https://oss-binaries.phusionpassenger.com/apt/passenger/) / [Passenger (RPM)](https://oss-binaries.phusionpassenger.com/yum/passenger/el/)

An example inventory configuration for the base OpenNebula repository would look like this:

```yaml
---
all:
  vars:
    # Use custom / local / insecure OpenNebula repo.
    opennebula_repo_force_trusted: true
    opennebula_repo_url:
      RedHat: http://10.11.12.13/repo/6.8/AlmaLinux/
      Ubuntu: http://10.11.12.13/repo/6.8/Ubuntu/22.04/
```

> [!IMPORTANT]
> The `*_force_trusted: true` parameter completely disables GPG key management and SSL verification for specific repos.

A complete list of parameters can be found in the [README](https://github.com/OpenNebula/one-deploy/blob/master/roles/repository/README.md) and in the [defaults](https://github.com/OpenNebula/one-deploy/blob/master/roles/repository/defaults/main.yml) of the repository for the role.

With all systems and the five mentioned repos appropriately configured, it should be possible to achieve airgapped installations. :+1:
