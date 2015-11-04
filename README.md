oraclexe Cookbook
=================
Chef cookbook for installing Oracle XE on Docker images. For details on the installation process consult the [official documentation](http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm#XEINL121).

The existing Chef cookbooks for Oracle XE don't work with most of the stripped down Docker images (e.g. the base [CentOS](https://www.centos.org/) images). Hence this cookbook. It installs some tools needed for the installation process and downloads the `rpm` via `wget`. So you need unzip and copy your `rpm` download (avaiable for free [here](http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html)) to a place accessible via `wget` (e.g. Dropbox) and provide the link via the `source` attribute to the recipe.

The cookbook works with Oracle XE 11.2.0 and CentOS. More constellations need to be tested...

Requirements
------------

#### swap space
- Make sure the swap partition on your machine is big enough. For instance, Oracle 11g XE requires 2048 MB of swap space. [Here](http://www.cyberciti.biz/faq/linux-add-a-swap-file-howto/)'s a general guide to increase the swap size on a Linux system. In case you're using Docker be aware that you cannot add a swap file to the container. Instead the hosting docker machine has to be adapted. @madhead provides a nice script in his [README](https://github.com/madhead/docker-oracle-xe/blob/master/README.md).

#### packages
- [`magic_shell`](https://github.com/customink-webops/magic_shell) - oraclexe needs magic_shell to set environment variables.

Attributes
----------
- `source` - specifies the URL where you've placed the Oracle 11g Express Edition RPM. Source must be accessible via wget.

- `oracle-home` - defines the directory where Oracle XE is installed and is used to set environment variables pointing to this directory.

- `oracle-sid` - sets the Oracle System ID (SID) identifying the database on your system

- `http-port` - port for the HTTP interface

- `listener-port` - sets listener port used to connect to Oracle XE

- `password` - initial password for administrative user accounts

- `dbenable` - specifies whether you want to start Oracle XE automatically on system start

#### oraclexe::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Default</th>
  </tr>
  <tr>
    <td colspan=3>Environment parameters:</td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['source']</tt></td>
    <td>URL</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['oracle-home']</tt></td>
    <td>String</td>
    <td><tt>'/u01/app/oracle/product/11.2.0/xe/</tt></td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['oracle-sid']</tt></td>
    <td>String</td>
    <td><tt>XE</tt></td>
  </tr>
  <tr>
    <td colspan=3>Oracle response file parameters:</td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['http-port']</tt></td>
    <td>Integer</td>
    <td><tt>8079</tt></td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['listener-port']</tt></td>
    <td>Integer</td>
    <td><tt>1521</tt></td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['password']</tt></td>
    <td>String</td>
    <td><tt>'oracle'</tt></td>
  </tr>
  <tr>
    <td><tt>['oraclexe']['dbenable']</tt></td>
    <td>Boolean</td>
    <td><tt>false</tt></td>
  </tr>
</table>

Usage
-----
#### oraclexe::default

e.g.
Just include `oraclexe` in your node's `run_list` and add at least the location of the Oracle XE `rpm`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[oraclexe]"
  ],
  "oracle-xe": {
    "url": "https://www.dropbox.com/s/FILE-ID/oracle-xe-11.2.0-1.0.x86_64.rpm"
  }
}
```

Acknowledgments
---------------
The configuration files `init.ora` and `initXETemp.ora` as well as the start script are taken from madhead/docker-oracle-xe

License and Authors
-------------------
License: Apache 2.0
Authors: Frank Wisniewski
