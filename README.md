irixboot
========

irixboot is designed to quickly configure a disposable VM to boot a specific version of the SGI IRIX installer over the network on an SGI machine without a whole lot of fuss. 

By default irixboot downloads IRIX 6.5.30 installation media from a mirror site. You can modify the media download URLs in the included Vagrantfile.

irixboot is not secure and may interfere with other network services (e.g. DHCP) so please don't leave it running long-term. I recommend only attaching the network interface to an isolated network for this purpose and then `vagrant halt` or `vagrant destroy` the VM when you are done installing.

The irixboot VM provides the following services:

* BOOTP server (via isc-dhcp)
* TFTP server (via tftpd-hpa)
* RSH server (via rsh-server)

NOTE: This fork no longer supports CD images. It may again in the future, if there is demand. If you must extract from CD media, see the upstream https://github.com/halfmanhalftaco/irixboot. 

## Requirements

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)
* VM host with TWO network interfaces
  * I very much recommend using a host with two built-in interfaces, such as one WiFi and one Ethernet
  * I have had great success with MacOS
  * Others have had great failures with Windows 10

I am not sure what range of IRIX versions this will work with or what SGI machines are compatible. Personal testing and user reports show the following (at minimum) should be compatible:

* Target Hardware
	* SGI O2
	* SGI Indigo
	* SGI Indigo2
	* SGI Octane

* Operating Systems
	* IRIX 6.5.22
	* IRIX 6.5.30

I suspect that most other hardware and OS versions released in those timeframes will also work (e.g. O2, server variants, etc.) SGI obviously kept the netboot/install process pretty consistent so I'd expect it to work on probably any MIPS-based SGI system. 

(feel free to send me a Personal IRIS or Tezro or something to test it on!)

Some changes will definitely be needed to support other hypervisors, but irixboot should work with VirtualBox on other systems as long as the `bridgenic` parameter is updated correctly. 

## Setup
By default, this vagrant VM will fetch proper 6.5.30 installation packages from ftp.irisware.net.


## Settings

These settings are found at the top of `Vagrantfile`. Edit them to suit your environment.

Set this to the version of IRIX you are installing. You must create a subdirectory in the `irix` directory with the same name:

```
irixversion = '6.5'
```
Set installmethod to either "ftp". installmirror is currently not used.

```
installmethod = "ftp"
installmirror = "ftp.irisware.net"
```

These should be obvious - the network parameters for the target SGI machine:

```
clientname = 'indy'
clientip = '192.168.42.100'
clientether = '08:00:69:CA:FE:42'
```

These are the common network parameters for your subnet:

```
domain = 'sgi.halfmanhalftaco.com'
netmask = '255.255.255.0'
```

This is the network configuration for the server VM. the `bridgenic` parameter is the interface name for the NIC (on your host machine - not in the VM) that is connected to the network your target is on. Since interface names can vary wildly between operating systems, you can list your system's interfaces as seen by VirtualBox with `VBoxManage list bridgedifs` - the `Name` parameter is the one it expects.

```
hostip = '192.168.42.5'
bridgenic = 'eth0'
```

NOTE: This VM starts a BOOTP server that will listen to broadcast traffic on your network. It is configured to ignore anything but the target system but if you have another DHCP/BOOTP server on the LAN segment the queries from the SGI hardware may get answered by your network's existing DHCP server which will cause problems. You may want to temporarily disable DHCP/BOOTP if you are running it on your LAN, configure it to not reply to queries from the SGI system, or put SGI hardware on a separate LAN (my recommendation).

## IRIX media from FTP
This VM can now sync installation media from the FTP site ftp.irisware.net. As this site contains more, and more recently updated, packages, it is the default. 

Vagrant will automatically create a vagrant/irix directory on your host machine that is shared between it and the VM. It will then fetch the installation media archives only if they are missing from that directory. 

## Booting

###### caveat: I am not an SGI expert by any means, this is just based on my experience as to what works.

### fx (Partitioner)

If you need to boot `fx` to label/partition your disk, open the command monitor and issue a command similar to this:

`bootp():/overlay30/stand/fx.ARCS`

where `/overlay30/stand/fx.ARCS` is a path relative to your selected IRIX version in the directory structure from above. When installing IRIX 6.5.x you'll want to use the partitioner included with the overlay set (first disc), but prior versions of IRIX usually locate the partitioner on the first install disc.

 Use `fx.ARCS` for R4xxx machines and `fx.64` for R5000+ machines (and others for older machines, I assume). Once `irixboot` finishes setup it lists any detected partitioners to help you find the correct path.

### inst (IRIX installer)
NOTE: After `irixboot` initializes, it displays a list of all `dist` subdirectories for your convenience. Use this list to preserve your sanity while running inst.

The installer can be reached through the monitor GUI as follows:

* At the maintenance boot screen, select "Install Software"
* If it prompts you for an IP address, enter the same address you entered into the Vagrantfile config for `clientip`.
* Use `irixboot` as the install server hostname.
* For the installation path, this depends on your directory structure. If you use the structure example from above, you would use the path `overlay30/dist`. Notice the lack of leading `/`.
* This should load the miniroot over the network and boot into the installer.
* To access the other distributions you extracted, use `open irixboot:<directory>/dist`.

## PRO TIP
Take a look in the expect/ directory for my own personal install scripts, written in expect. You can use them as a guide for what to select during an installation -- or if you're really brave/foolish, follow the enclosed README to run those scripts over serial console.

## TODO
* Make the download phase provide more feedback.
* Confirm if the download phase really downloads every time, or is smart enough to skip already-downloaded items.

## License

MIT License

Portions of this project are:
Copyright (c) 2018 Andrew Liles
Copyright (c) 2018 Eric Dodd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
