[//]: # ( vim: set wrap : )

# Airgapped installation

Currently one-deploy does not provide a focused way to do airgapped installations.

Since the release `1.1.1` it should be possible however to configure/override all five APT/DNF repositories that one-deploy uses, including:

- [Ceph Community](https://download.ceph.com/)
- [Free Range Routing (DEB)](https://deb.frrouting.org/) / [Free Range Routing (RPM)](https://rpm.frrouting.org/)
- [Grafana (DEB)](https://apt.grafana.com/) / [Grafana (RPM)](https://rpm.grafana.com/)
- [OpenNebula (CE)](https://downloads.opennebula.io/repo/) / [OpenNebula (EE)](https://enterprise.opennebula.io/repo/)
- [Passenger (DEB)](https://oss-binaries.phusionpassenger.com/apt/passenger/) / [Passenger (RPM)](https://oss-binaries.phusionpassenger.com/yum/passenger/el/)

> [!WARNING]
> Of course the prerequisite is that all the machines OpenNebula will be deployed on, should use mirrored repositories for system DEB/RPM packages.

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
> The `*_force_trusted: true` parameters disable completely GPG key management and SSL verification for specific repos.

Complete list of parameters can be found in the [README](https://github.com/OpenNebula/one-deploy/blob/master/roles/repository/README.md) and in the [defaults](https://github.com/OpenNebula/one-deploy/blob/master/roles/repository/defaults/main.yml) of the repository the role.

With all the system and the five mentioned repos configured it should be possible to achieve airgapped installations. :+1:
