[//]: # ( vim: set wrap : )

# Verifying the Installation

This page is a quick guide for verifying your OpenNebula cloud installed with `one-deploy`. The cloud was created using the inventory files showed in the examples, so you may need to adapt IPs and host names to your infrastructure.

## Check the OpenNebula Resources

To check the hypervisor nodes, first ssh into the Front-end. Then, become the `oneadmin` user and verify the hosts registered in OpenNebula. Run these commands:

```
sudo -i -u oneadmin
onehost list
```

Sample output below. Verify that `STAT` is `on` and not `err`:

```
root@ubuntu2204-14:~# sudo -i -u oneadmin
oneadmin@ubuntu2204-14:~$ onehost list
  ID NAME                                               CLUSTER    TVM      ALLOCATED_CPU      ALLOCATED_MEM STAT
   1 172.20.0.9                                         default      0       0 / 100 (0%)     0K / 1.4G (0%) on
   0 172.20.0.8                                         default      0       0 / 100 (0%)     0K / 1.4G (0%) on
```

Similarly, you can check the datastores with:

```
onedatastore list
```

In the output below, note that the `TM` column shows that all datastores use `ssh` drivers:

```
oneadmin@ubuntu2204-14:~$ onedatastore list
  ID NAME                                                      SIZE AVA CLUSTERS IMAGES TYPE DS      TM      STAT
   2 files                                                    19.2G 84% 0             0 fil  fs      ssh     on
   1 default                                                  19.2G 84% 0             0 img  fs      ssh     on
   0 system                                                       - -   0             0 sys  -       ssh     on
```

> [!NOTE]
> If you deployed using shared storage, the `TM` column should display `shared` for the `system` and `default` datastores.

Finally, check the virtual networks created as part of the deployment:

```
onevnet list
```

In the output, ensure that the `STATE` column displays "ready" (`rdy`):

```
oneadmin@ubuntu2204-14:~$ onevnet list
  ID USER     GROUP    NAME                            CLUSTERS   BRIDGE            STATE        LEASES OUTD ERRO
   0 oneadmin oneadmin admin_net                       0          br0               rdy               0    0    0
```

## Import a Marketplace Appliance

> [!NOTE]
> This requires internet access for the Front-end.

To create a test VM, first download an image from the OpenNebula Marketplace, in this case an Alpine Linux image:

```
onemarketapp export -d default 'Alpine Linux 3.17' alpine
```

The image will be downloaded and assigned ID `0`:

```
oneadmin@ubuntu2204-14:~$ onemarketapp export -d default 'Alpine Linux 3.17' alpine
IMAGE
    ID: 0
VMTEMPLATE
    ID: 0
```

Verify that the Alpine image is ready, running:

```
oneimage list
```

In the output, verify that the `STAT` column displays `rdy`:

```
oneadmin@ubuntu2204-14:~$ oneimage list
  ID USER     GROUP    NAME                                                 DATASTORE     SIZE TYPE PER STAT RVMS
   0 oneadmin oneadmin alpine                                               default       256M OS    No rdy     0
```

## Create a Test VM

Finally, create a VM based on the Alpine template, attaching it to the `admin_net` network:

```
onetemplate instantiate --nic admin_net alpine
```

Output should display the ID for the VM, in this case `0`:

```
oneadmin@ubuntu2204-14:~$ onetemplate instantiate --nic admin_net alpine
VM ID: 0
```

Wait for the VM to reach the `running`. You can check with:

```
onevm top
```

Verify that `STAT` displays `runn`:

```
onevm top
  ID USER     GROUP    NAME                                 STAT  CPU     MEM HOST                           TIME
   0 oneadmin oneadmin alpine-0                             runn    1    128M 172.20.0.9                 0d 01h50
```

Finally, verify VM connectivity. In this example the VM will be using the first IP in the virtual network range, 172.20.0.100:

```
oneadmin@ubuntu2204-14:~$ ping -c 2 172.20.100
PING 172.20.100 (172.20.0.100) 56(84) bytes of data.
64 bytes from 172.20.0.100: icmp_seq=1 ttl=64 time=1.07 ms
64 bytes from 172.20.0.100: icmp_seq=2 ttl=64 time=1.13 ms

--- 172.20.100 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 1.069/1.098/1.128/0.029 ms
```
## Check the Sunstone Web UI

As part of the deployment, the Sunstone web interface is installed in the OpenNebula Front-end. You can check that it is up and running by pointing your browser to the Front-end IP on port 2616, for example `http://172.20.0.7:2616`. Log in as user `oneadmin`, using the password supplied in the inventory file (`opennebulapass` parameter). You should see the Sunstone Dashgoard:

[[images/sunstone.png|Sunstone main dashboard]]
