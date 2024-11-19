[//]: # ( vim: set wrap : )

# The "generic" Datastore Mode

The "simple" datastore configration mode is limited to only 3 basic datastores (IDs 0, 1, 2):

```yaml
ds:
  mode: ssh
  mounts:
  - type: system
    path: /mnt/one_datastores/system/
  - type: image
    path: /mnt/one_datastores/default/
  - type: files
    path: /mnt/one_datastores/files/
```

Fortunately, it's possible to define datastores more freely with the "generic" mode, for example:

```yaml
ds:
  mode: generic
  config:
    SYSTEM_DS:
      system:
        enabled: false
      system1:
        id: 100
        symlink:
          groups: [node]
          src: /mnt/nfs1/100/
        template: &template
          TYPE: SYSTEM_DS
          TM_MAD: shared
          BRIDGE_LIST: "{{ groups.node | map('extract', hostvars, ['ansible_host']) | join(' ') }}"
      system2:
        id: 101
        symlink:
          groups: [node]
          src: /mnt/nfs2/101/
        template: *template
      system3:
        id: 102
        symlink:
          groups: [node]
          src: /mnt/nfs3/102/
        template: *template
    IMAGE_DS:
      default:
        symlink: { src: /mnt/nfs0/1/ }
        template:
          TM_MAD: shared
    FILE_DS:
      files:
        symlink: { src: /mnt/nfs0/2/ }
```

With the "generic" mode it's actually possible to configure any number of user-defined datastores, for example:

```yaml
    SYSTEM_DS:
      system1:
        id: 100
        symlink:
          groups: [node]
          src: /mnt/nfs1/100/
        template: &template
          TYPE: SYSTEM_DS
          TM_MAD: shared
          BRIDGE_LIST: "{{ groups.node | map('extract', hostvars, ['ansible_host']) | join(' ') }}"
```

Where:

- `system1` is a name assigned to the new user-defined datastore
- `id` is a **predicted** or **existing** datatore ID (OpenNebula always starts numbering user-defined datastores from `100`)
- `symlink` is optional, if defined then `groups` should be used to specify where the actual symlinking has to happen, `src` specfies the source directory that is going to be symlinked as `/var/lib/one/datastores/<id>` (unless it's `/var/lib/one/datastores/`, then it must be skipped)
- `template` is an usual raw (expressed in YAML) OpenNebula template for the datastore


> [!WARNING]
> When creating user-defined datastores you must provide **predicted** datastore IDs starting from `100`, then incrementing by `1` for subsequent ones. Or, if datatores already exist you can tell one-deploy to start/continue managing them by providing **existing** datastore IDs.

For the reference, the default "generic" mode configuration (which can be considered an equivalent for the "simple" mode) is:

```yaml
SYSTEM_DS:
  system:
    id: 0
    managed: true
    enabled: true
    symlink:
      groups: [node]
      src: /var/lib/one/datastores/ # this skips symlinking
    template:
      TYPE: SYSTEM_DS
      TM_MAD: ssh
IMAGE_DS:
  default:
    id: 1
    managed: true
    symlink:
      groups: [frontend, node]
      src: /var/lib/one/datastores/ # this skips symlinking
    template:
      TYPE: IMAGE_DS
      DS_MAD: fs
      TM_MAD: ssh
FILE_DS:
  files:
    id: 2
    managed: true
    symlink:
      groups: [frontend]
      src: /var/lib/one/datastores/ # this skips symlinking
    template:
      TYPE: FILE_DS
      DS_MAD: fs
      TM_MAD: ssh
```
