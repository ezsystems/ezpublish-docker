# eZ Publish5 in Docker

Project is work in progress!

Aims to provide setup for _eZ Platform_(also implies _eZ Studio_) using Docker containers and Docker Compose(fig), either natively on linux if you have docker and fig installed, or via VM using Vagrant and Virtualbox/AWS.
_Note: The use of Vagrant will probably be faded out in favour of Docker Machine in the future._

## Project goal

To make sure same environment can be used across every all steps from developer, QA, support to production further aims to cover the following internal and later external user stories:

1. Single server for internal Product Development use _(more or less in order)_:
 - As a PM I want a Virtual machine for eZ Platform
 - As a PM I want Sprint demos of latest eZ Platform dev version on AWS
 - As QA Engineer I want to run BDD Acceptance tests on containers, _in future across all supported platforms_
 - As maintainer I want to use stock Docker containers, _& potentially move QA specific containers to separate repo_
 - As PM I want demo system to use Solr/ES which is future recommendation for search over SQL
 - As eZ QA Tester I want a reference certification environment for testing eZ Platform, needs:
     - Apache
     - CentOS
     - Cluster (see below)
 - As eZ Developer/Support I want containers to be easier to use for debugging eZ Platform


2. Additional internal user stories that will affect/reuse work done here _(not in order)_:
 - As Sales/Partner I want access to demo setup for eZ Platform releases
 - As PS/Partner I want access to:
     - Install custom bundles
     - Switch to dev mode
     - Create own bundles and code for demo use (src)
     - Configure eZ Platform
 - As eZ Sysadmin I want a eZ Platform container setup able to scale performance wise .. ("Cluster")
     - Implies investigation of solutions like Docker Swarm, Apache Mesos, Google Kubernetes, combinations, ..


3. At some point we will also aim for covering external user story:
 - As a Developer/Sysadmin I want official containers to run eZ Platform on a environment _tailored_ by eZ


### Spec

All Docker service containers, aka micro services, like Nginx, Apache, Mysql, Varnish, Solr and so on should ideally have no direct knowledge of eZ Platform.
Injection of configuration should be done at startup by either passing env variables and/or mounting generic configuration files.
The motivation for this is to be able to contribute our generic extensibility needs upstream to official docker containers.


However this is currently not the case and we are looking for ways to best accomplish this while still being able to restart host and containers.

## Installation

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

### AWS specific procedures

If you want to use an elastic IP you need version 0.5.1 of the vagrant-aws plugin ( currently in development ). The easiest way to do this is to use the provided container.
You may also use this container if you simply do not want to install vagrant on your system.

In order to create the container image, run :
```docker build --rm=true --force-rm=true -t ezpublishdocker_vagrantaws:latest dockerfiles/vagrant-aws/```

In order to use this image, use the vagrant wrapper instead of using the vagrant installed directly on your system:
./vagrant-aws.sh [vagrant options]

Example #1:
./vagrant-aws.sh up --provider=aws

Example #2:
./vagrant-aws.sh up provision

As you can see, the wrapper will pass on any provided parameters to the vagrant process inside the container.


### Vagrant specific procedures
- Ensure you have the following tools installed on our computer:
 - Vagrant 1.6+ (http://vagrantup.com)
 - VirtualBox 4.3.12+ (http://www.virtualbox.org)
 - If using AWS: Install Vagrant AWS plugin. To install run vagrant ```vagrant plugin install vagrant-aws```
   If using the vagrant container above, this step is not needed
- Optionally: Enable etcd ( See chapter "About etcd " about why you would run etcd )
 - In files/fig.config, make sure "START_ETCD=yes"
 - Copy files/user-data-EXAMPLE (optionally files/user-data-EXAMPLE-AWS ) to files/user-data and provide a discovery token as instructed in the file
- If using AWS : 
 - In files/vagrant.yml, define "use_aws=true"
 - Create a dummy box: ```vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box```
 - You likely want web server to listen on port 80, not port 8080. If so, you need to change "8080:80" into "80:80" in the nginx section in fig.yml ( unfortunately, this cannot be a setting in files/fig.config ) 
- Run `vagrant up`

If you later want to do changes to your docker/vagrant files, you need to stop and remove the corresponding container ```docker stop [containerid]; docker rm [containerid]```, remove the image ```docker rmi [imageid]``` and then run ```vagrant provision``` instead of ```vagrant up```

#### IMPORTANT difference between provision on virtualbox vs AWS
When using virtualbox as provisioner, ```vagrant provision``` will *not* rsync your local changes over to the VM. Only a ```vagrant up```will do that.
When using AWS as provisioner, ```vagrant provision``` *will* run rsync. This is likely NOT the behaviour you want as this will overwrite db and ezpublish volumes on AWS machine every time you provision.
To prevent this from happening when provisioning on AWS, use the setting "disable_rsync: yes" in vagrant.yml

If you do changes in configuration files or docker files you may run this commands in order to sync them the VM:
```cd ezpublish-docker```
```rsync -avq --delete --exclude ".git/" --exclude "volumes/ezpublish/.git/" --exclude ".vagrant" --exclude volumes . core@1.2.3.4:/vagrant```

where "1.2.3.4" is the IP if the virtual machine

Please note that running ```vagrant rsync```will also delete any volumes in VM and instead copy over those you have locally

### Setting up etcd
CoreOS has support for running etcd out of the box, it just needs to be configured:
 - Visit https://discovery.etcd.io/new to generate a discovery token. This token will be used internally by etcd
 - Copy files/user-data-EXAMPLE (optionally files/user-data-EXAMPLE-AWS ) to files/user-data and provide a discovery token
 - In files/fig.config, make sure "ETCD_ENABLED=yes"

Note: When running etcd on the host, you'll need to remove or change port numbers for etcd in fig.yml too (example : "4002:4001", "7002:7001" ), to prevent the etcd container from binding to the default etcd ports. This is only needed with docker 1.3 and later as earlier version would not complain if the given ports were already taken
Note: If you recreates the VM ( for instance by doing ```vagrant destroy```, you'll need to regenerate a new token before running ```vagrant up```. Failing to do so will prevent etcd from starting !

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

### Varnish

These are the steps needed in order to get varnish running
 - Set ```VARNISH_ENABLED=yes"```in fig.config.
 - Run ```fig.sh up -d``` or ```fig.sh up -d --no-recreate``` as usual
 - Run the eZ Publish Setup Wizard
 - Start the varnishprepare container in order to configure eZ Publish to use a http cache in ezpublish/config/ezpublish.yml : ```fig -f fig_[ubuntu|debian].yml start varnishprepare```
   This varnishprepare container has some requirements:
   - Please note that this container must be run *after* setup wizard has been created. If you run it before SW, the ezpublish.yml is yet not generated and the varnishprepare container will abort 
   - In order to inject the settings correctly in ezpublish.yml, your ezpublish.yml should not differ too much from the standard ezpublish.yml generated by the setup wizard
   - The varnishprepare container assumes your siteaccess group is called "ezdemo_site_clean_group" or "ezdemo_site_group:" ( which is the defaults when installing "Demo site with(out) demo content" )
 - If the varnishprepare container is not able to configure ezpublish correctly on your setup, please follow the instructions in the "Update YML configuration" chapter on https://doc.ez.no/display/EZP/Using+Varnish
 - If container do not work as expected, you may inspect the log using ```docker logs ezpublishdocker_varnishprepare_1```
 - The ```docker logs ....``` will output the IP of the varnish container which you need in order to configure ezpublish.yml manually


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