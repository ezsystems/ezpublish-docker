# eZ Publish5 in Docker

eZ Publish Inception, installed in docker containers, inside a virtual machine (configurable in VagrantFile).
Project is work in progress!

## Project goal

Cover the following use cases (with time), including (in prioritized order):

1.  Single server images, for use by:
 1.  Sprint / Release Demo (PS, Sales, PM)
 2.  Testing (QA, Support, Dev)
 3.  Production (internal Ops, but potentially also partners)
2.  Cluster support (Memcached, Varnish4, DFS)
3.  Add additional containers for the different platforms we support to be able to automate Behat (BDD) testing across
    a wide range of platforms and combinations.
4. (outside scope of this Repository) Investigate use of Meos++ for use with massive clustering


### Spec

#### "Host" (VM Guest when using Vagrant)

Host machine is running CoreOS allowing us to not have to maintain the host (autoupdate), have a light host OS,
and allowing us to take advantage of its clustering capabilities in the future.

eZ Publish is placed in volumes/ezpublish as rsynced by Vagrant to /vagrant/volumes/ezpublish on virtual machine.
Mysql raw files are in similar ways located in volumes/mysql

    Port (Listen): 80
    Software: CoreOs

#### Configuration

In the beginning VagrantFile will be used, and config is up to user to adjust eZ Publish install and VagrantFile.

However eventually the following needs to be configured in a "Docker way"(TM):
- Container linking (typically fig or Meos for cluster setup or manually using Weave)
- Configuring of eZ Publish (typically using Ansible)
    - database (example: mysql/postgres/oracle/..)
    - cache (example: memcached/file/redis/..)
    - http cache (example: varnish4/nginx/file/..)
    - search (example: solr/es/db/..)
    - io (example: file/nfs/s3/..)


#### Docker Images

As much as possible we would like to reuse existing images out there by contributing features to them.
A lot of existing images exists for ubuntu and debian.

##### Images varying by Base

Base images are provided by Docker, and the once we would like to use are currently (prioritized):
- `centos:centos7`
- `ubuntu:trusty`
- `debian:wheezy` (for later, might make sense ot wait for `debian:jessie`)
- `opensuse:latest` (for later, if/when we re add suse to supported platforms)

For test coverage of our different supported platforms we would thus like to eventually have the following images
either from docker hub or home grown implemented using all the listed base images above:

###### DB

    Port (Listen): <depends on server>
    CMD: start db service
    Software: mysql/mariadb, postgres, ..
    On run:
        Should 1. create database and give rights to a user, 2. accept existing database dump


###### HTTPD

    Port (Listen): 80
    CMD: start httpd service
    Software: Nginx, Apache
    Volume: .vagrant/ezpublish mounted to for instance /var/www
    Configuration:
        FastCGI on port 9000
        VirtualHost config with <volume-mount-dir>/web as configured as web root (at docker run before starting server?)


###### PHP

Image to use both as php-fpm (fast cgi) container, as cronjob container running php scripts and can be used
for starting own instance on demand for running own php commands against the eZ install.

    Port (Listen): 9000
    Software: php-fpm, php-cli
    Volume: .vagrant/ezpublish mounted to for instance /var/www
    Configuration:
        Configure php-fpm to execute on <volume-mount-dir>/web.

Should probably be a dev version extending this adding all kind of debug things like xdebug and modifying settings.


##### Other images

List of images that does not need to be strictly tested on the misc distros.
TBD but if we continue with a Reference platform these should use CentOS, if not we are free to choose.

###### Memcached
###### Varnish v4
###### Solr
###### Elastic Search
###### NFS


### Docker images

These should be refactored in the future to be something like the following list of containers:
- http server with fastcgi
- php fpm for serving php
- crontab container with php cli
- Database: Mysql|Postgres|..
- Clustering:
 - Cache: Memcached|Redis|..
 - HTTP cache: Varnish|Nginx|..
 - FS: NFS|GridFS|..  (services like S3 might not need a container, but could have a container acting as proxy)

**Note** We should take advantage of official images from Docker as much as possible, however they now use Debian
as it takes less space then Ubuntu, and for lowest space use (and memory?) base images should be the same across
all our official images.

And development mode or not should probably rather be a global parameter then special images.

However right now following images exists:

## Installation

NB: This section reflects current status with images not reflecting spec above!
The containers can be created and started using either vagrant or fig. Vagrant will create a virtual machine where the containers are running while fig will create the containers on host ( requires linux....)

### About etcd 
If you want to be able to start and stop containers in arbitrary order ( like db, phpfpm and nginx containers ), you'll need have etcd ( https://coreos.com/docs/distributed-configuration/getting-started-with-etcd/ ) running.
Etcd is a open-source distributed key value store that is used to provides shared configuration among the containers.
If you do *not* run etcd and you start/stop containers without using fig.sh, you have to make sure that containers are started in this order : ezpublishdocker_db1_1, ezpublishdocker_phpfpm_1, ezpublishdocker_nginx_1
This means that if you for some reason has to restart ezpublishdocker_db1_1, you also have to restart the other two containers, and in correct order.

See below for instructions for how to run etcd


### Default system

By default, the following system will be installed:
 - Vagrant will create a virtual machine using VirtualBox. This VM will run CoreOS
 - eZ Publish Community version v2014.11.0 will be installed
 - eZ Publish will be available on port 8080 on the VM

### Optional installation steps

- Copy files/fig.config-EXAMPLE to files/fig.config ( and set the environment variables in files/fig.config according to your needs if you want to change the default setup ).
- Copy files/auth.yml-EXAMPLE to files/auth.yml.
  This file has two authentication sections:
  - The setting for updates.ez.no is applicable if you want to install eZ Publish Enterprise and not the community version
  - The setting for github.com is applicable when doing installations via composer ( which is default ). It will raise certain API bandwidth limitations on github.
    In order to create a github oauth token, please follow instructions on this page : https://help.github.com/articles/creating-an-access-token-for-command-line-use To revoke access to this github oauth token you can visit https://github.com/settings/applications
- Copy files/vagrant.yml-EXAMPLE to files/vagrant.yml. Then adjust settings in .yml file as needed
- If you have an existing ezpublish installation you want to use, do the following :
 - Place the installation in volumes/ezpublish
 - Make sure EZ_INSTALLTYPE is set to "basic"
 - You need to manually import the database from the php-cli container ( see chapter "Running php-cli and mysql commands" )
   This needs to be done after all images and containers has been created ( after you have executed "vagrant up" or "./fig.sh up -d" )
   For convenience, you should also place the database dump in volumes/ezpublish so you may easily access it from the php-cli container

Note : If you opt not to copy the configurations files mentioned above ( the *.-EXAMPLE files ), the system will do so for you and use default settings.

### Vagrant specific procedures
- Ensure you have the following tools installed on our computer:
 - Vagrant 1.6+ (http://vagrantup.com)
 - VirtualBox 4.3.12+ (http://www.virtualbox.org)
 - If using AWS : Vagrant AWS plugin. To install run vagrant ```sudo vagrant plugin install vagrant-aws```
- Optionally: Enable etcd ( See chapter "About etcd " about why you would run etcd )
 - In files/fig.config, make sure "START_ETCD=yes"
 - Copy files/user-data-EXAMPLE (optionally files/user-data-EXAMPLE-AWS ) to files/user-data and provide a discovery token as instructed in the file
- In files/fig.config, make sure "FIX_EXECUTION_PATH=/"
- If you are going to use AWS, you'll need to create a dummy box:
  ```vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box```
- If you are going to use AWS, you likely want web server to listen on port 80, not port 8080. If so, you need to change "8080:80" into "80:80" in the nginx section in fig.yml ( unfortunately, this cannot be a setting in files/fig.config ) 
- Run `vagrant up`

If you later want to do changes to your docker/vagrant files, you need to stop and remove the corresponding container ```docker stop [containerid]; docker rm [containerid]```, remove the image ```docker rmi [imageid]``` and then run ```vagrant provision``` instead of ```vagrant up```

#### IMPORTANT difference between provision on virutalbox vs AWS
When using virutalbox as provisioner, ```vagrant provision``` will *not* rsync your local changes over to the VM. Only a ```vagrant up```will do that. 
When using AWS as provisioner, ```vagrant provision``` *will* run rsync. This is likely NOT the behaviour you want as this will overwrite db and ezpublish volumes on AWS machine every time you provision.
To prevent this from happening when provisioning on AWS, use the setting "disable_rsync: yes" in vagrant.yml

If you do changes in configuration files or docker files you may run this commands in order to sync them the VM:
```cd ezpublish-docker```
```rsync -avq --delete --exclude ".git/" --exclude "volumes/ezpublish/.git/" --exclude ".vagrant" --exclude volumes . core@1.2.3.4:/vagrant```

where "1.2.3.4" is the IP if the virtual machine

Please note that running ```vagrant rsync```will also delete any volumes in VM and instead copy over those you have locally

### Specific procedures when running containers on local host, not in VM using Vagrant
- Ensure you have the following tools installed on your computer:
 - docker version 1.2 or later ( https://docs.docker.com/installation/ubuntulinux/ ) 
   PS : ubuntu ships with 0.9.1 and this version won't do due to lack of https://github.com/docker/docker/pull/5129/commits 
 - Fig version 1.0.0 or later ( http://www.fig.sh/install.html )
 - nsenter ( optionally, if you want to start a shell inside a running container : https://github.com/jpetazzo/nsenter )
- If you want to run etcd, you have two options, running etcd on the host directly, or in a container
 - If you want to run etcd on the hosts and your distribution do not have etcd packages, this url might be of help:
  - http://blog.hackzilla.org/posts/2014/09/18/etcd-for-ubuntu
 - The easiest method is to run etcd in a container:
  - In files/fig.config, make sure "START_ETCD=yes"
  - In files/fig.config, make sure "ETCD_DISCOVERY=autogenerate" or "ETCD_DISCOVERY=https://discovery.etcd.io/[discovery_hash]"
  - In files/fig.config, make sure "ETCD_ENABLED=yes"
    If you want to manually create a discovery hash, access https://discovery.etcd.io/new in a browser
- Run `./fig.sh up -d`

If you later just want to recreate specific images or containers, you then first remove those using `docker rm [container]` and `docker rmi [image]`, and then run
`fig.sh up -d --no-recreate`

fig.sh is a wrapper for fig which also do some internal provisioning. Any command line arguments used when starting the wrapper is passed on to fig.

### Access your eZ Publish installation

When the containers are created, you should be able to browse to eZ Publish setup wizard by going to http://[VM_IP_ADDR]:8080/ if using vagrant and http://localhost:8080/ if running the containers on localhost 


#### SSH

##### VM

To enter virtual machine:
- ```vagrant ssh```

From there you can check running containers:
- ```docker ps```

And inspect the eZ Publish folder which was rsynced into the vm and is used as volume for eZ Publish container:
- ```ls -al /vagrant/ezpublish/```


##### Running php-cli and mysql commands

To run php/mysql commands you'll need to start a new container which contains php-cli:
- ```vagrant ssh```
- ```docker run --rm -i -t --link ezpublishdocker_db1_1:db --dns 8.8.8.8 --dns 8.8.4.4 --volumes-from ezpublishdocker_ezpublishvol_1 --volumes-from ezpublishdocker_composercachevol_1 ezpublishdocker_phpcli /bin/bash```

If running the containers on localhost, you have to skip the ```vagrant ssh``` of course

From there you can run symfony commands like normal:
- ```php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env dev``

You can also access mysql from this container as it has the mysql client installed:
- ```mysql -uadmin --password=[mysqlpasswd] --protocol=tcp --host=db```

Mysql password is defined in files/fig.config

( For other environment variables see ```env```, basically these typically comes from parent images and links )

To get out, type ```exit``` two times ;)


##### The containers

Once you have the system up, doing a ```docker ps -a``` will reveal that the following containers:
 - ezpublishdocker_nginx_1
  - This container runs the nginx process
  - This container will on startup look for nginx configuration files in volumes/ezpublish/doc/nginx/etc/nginx/. If this directory do not exists when the container start, it will fallback to use configuration files stored inside the container.
  - It is important to understand that the folder volumes/ezpublish/doc/nginx/etc/nginx/ will typically not exists if volumes/ezpublish is empty when you start fig.sh as the nginx container will start before the ezpublishdocker_prepare_1 container is completed.
 - ezpublishdocker_phpfpm_1
  - This is the container that runs the phpfpm process
 - ezpublishdocker_db1_1
  - This is the container running the database
 - ezpublishdocker_dbvol_1
  - This container is stopped ( meaning no processes are running in it). This is correct. The container is only a data volume containers for the mysql raw db files
  - The content of the data volume container is mapped to /vagrant/volumes/mysql/ on VM ( volumes/mysql/ if running containers on localhost ). 
  - If you want to reset the mysql databases, you'll need to stop and remove this container, remove all files in volumes/mysql and make sure that is synced to VM ( /vagrant/volumes/mysql ), then recreate ezpublishdocker_dbvol_1 container
 - ezpublishdocker_ezpublishvol_1
  - This container is stopped ( meaning no processes are running in it ). This is correct. The container is only a data volume containers for the ezpublish files
  - The content of the data volume container is mapped to /vagrant/volumes/ezpublish/ on VM. 
  - For replacing the ezpublish files, you simply needs to change the files in volumes/ezpublish and ( if using  vagrant : ) sync this over to the VM 
 - ezpublishdocker_prepare_1
  - This is the container responsible for configuring eZ Publish ( according to EZ_INSTALLTYPE and other settings ). Once eZ Publish is configured, the container will stop 
 - ezpublishdocker_phpcli_1
  - This container is not used for anything, but fig do not currently support create a image from dockerfiles without also creating a container.
 - ezpublishdocker_etcd_1
 - ezpublishdocker_phpclibase_1
  - This container is not used for anything, but fig do not currently support create a image from dockerfiles without also creating a container.
 - ezpublishdocker_composercachevol_1
  - This container is a data volume container for the composer cache
 - ezpublishdocker_ubuntu_1
  - This container is not used for anything, but fig do not currently support create a image from dockerfiles without also creating a container.

##### Running vagrant from windows

It is possible to run this from Windows. However, it is not possible to use synced_folder with type virtualbox ( seems to be some incompatibility between virtualbox and docker's provision plugin in Vagrant or between CoreOS and Vagrant ? )
So, you need to use rsync on Windows too. In order to do this, you need rsync and ssh.
Easiest way to accomplish this is to install MinGW ( minimalist GNU for Windows ), http://sourceforge.net/projects/mingw/files/MSYS/Extension/rsync/rsync-3.0.8-1/
Download wingw-get-setup.exe and install openssh and rsync. You should then add "C:\MinGW\msys\1.0\bin" to your path and you should be all set to run "vagrant up"