# eZ Platform, eZ Studio & eZ Publish Platform 5.3+ in Docker

*Project is work in progress!*

Aims to provide setup for _eZ Platform_(also implies _eZ Studio_) using Docker containers and Docker Compose, either natively on linux if you have docker and docker-compose installed, or via VM using Vagrant and Virtualbox/AWS.
_Note: The use of Vagrant will probably be faded out in favour of Docker Machine in the future._

## Project goal

Two things:
- Provide an (eventually) official php image for use with eZ Platform, able to configure itself on startup. On top of that:
 - By extended container or otherwise: support for eZ Publish 5.3+ *(fixes will be made on upstream 5.3.x/5.4.x to make this possible)*
 - By extended container or otherwise: support debugging/development mode use cases and other PHP versions
- Provide a wide range of docker-compose setups for the different ways to setup eZ Platform, using thirdparty official docker images *(apache, nginx, mysql, mariadb, solr, varnish, memcached, redis, ..)*


The docker-compose setups aims to cover specific setups.
And the aim is that the yml files can easily be customized to change version to test for QA/Support/Reproduction needs.
- (default) Single server using mysql: nginx, mariadb
- Cluster using mysql *(sharing volume, so on one machine)*: nginx, mysql, memcached, varnish
- Single server postgres: apache (fastcgi), postgres

With this everything should be in place for easily evaluating adding postgres cluster support, adding redis support,
shared files system for scalability testing, and much more..


## Installation

The containers can be created and started using either vagrant or docker-compose. Vagrant will create a virtual machine where the containers are running while docker-compose will create the containers on host ( requires linux....)

### Default system

By default, the following system will be installed:
- Vagrant will create a virtual machine using VirtualBox. This VM will run CoreOS
- Latest eZ Platform will be installed (any distribution available over *composer create-project* should work)
- eZ Platform will be available on http://33.33.33.53:8080 on the VM

### Optional installation steps

- Copy files/docker-compose.config-EXAMPLE to files/docker-compose.config ( and set the environment variables in files/docker-compose.config according to your needs if you want to change the default setup ).
- Copy files/auth.yml-EXAMPLE to files/auth.yml.
  This file has two authentication sections:
 - The setting for updates.ez.no is applicable if you want to install eZ Publish Enterprise/eZ Platform LTS/eZ Studio and not the community version
 - The setting for github.com is applicable when doing installations via composer ( which is default ). It will raise certain API bandwidth limitations on github.
   In order to create a github oauth token, please follow instructions on this page : https://help.github.com/articles/creating-an-access-token-for-command-line-use To revoke access to this github oauth token you can visit https://github.com/settings/applications
 - Adding a github oauth token will in most cases INCREASE the performance of the installation process and is therefore HIGHLY recommended.
- Copy files/vagrant.yml-EXAMPLE to files/vagrant.yml. Then adjust settings in .yml file as needed
- If you have an existing ezpublish installation you want to use, do the following :
 - Place the installation in volumes/ezpublish
 - Make sure EZ_INSTALLTYPE is set to "basic"
 - You need to manually import the database from the php-cli container ( see chapter "Running php-cli and mysql commands" )
   This needs to be done after all images and containers has been created ( after you have executed "vagrant up" or "./docker-compose.sh up -d" )
   For convenience, you should also place the database dump in volumes/ezpublish so you may easily access it from the php-cli container

Note : If you opt not to copy the configurations files mentioned above ( the *.-EXAMPLE files ), the system will do so for you and use default settings.


### AWS specific procedures

If you want to use an elastic IP you need version 0.5.1 of the vagrant-aws plugin ( currently in development ). The easiest way to do this is to use the provided container.
You may also use this container if you simply do not want to install vagrant on your system.

In order to create the container image, run :
```docker build --rm=true --force-rm=true -t ezpublishdocker_vagrantaws:latest dockerfiles/internal/vagrant-aws/```

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
 - Copy files/user-data-EXAMPLE (optionally files/user-data-EXAMPLE-AWS ) to files/user-data and provide a discovery token as instructed in the file
- If using AWS : 
 - In files/vagrant.yml, define "use_aws=true"
 - Create a dummy box: ```vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box```
 - You likely want web server to listen on port 80, not port 8080. If so, you need to change "8080:80" into "80:80" in the nginx section in docker-compose.yml ( unfortunately, this cannot be a setting in files/docker-compose.config )
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

### Specific procedures when running containers on local host, not in VM using Vagrant
- Ensure you have the following tools installed on your computer:
 - docker version 1.6 or later ( https://docs.docker.com/installation/ubuntulinux/ )
 - Docker-Compose version 1.3.0 or later ( http://docs.docker.com/compose/install/ )
- Run `./docker-compose.sh up -d`

If you later just want to recreate specific images or containers, you then first remove those using `docker rm [container]` and `docker rmi [image]`, and then run
`./docker-compose.sh up -d --no-recreate`


### build.sh

build.sh will build the "service" images you need in order to run eZ Platform. By "service" image we mean the nginx and php images. No customized db image is currently needed as the official MariaDB docker image is used. 

### docker-compose_ezpinstall.sh

docker-compose_ezpinstall.sh is a script which will download eZ Platform via composer and install it in volumes/ezpublish. You may specify parameters to composer using EZ_COMPOSERPARAM variable in files/docker-compose.config.
docker-compose_ezpinstall.sh will automaticly by run when running ```vagrant up``` and ```vagrant provision```.

### docker-compose.sh

docker-compose.sh is a wrapper for docker-compose which also do some internal provisioning. Any command line arguments (except "-c configfile" ) used when starting the wrapper is passed on to docker-compose.
docker-compose.sh also accepts one special argument for specifying a alternative configuration file ( files/docker-compose.config is the default one if "-c ..." is not provided ).
Example : 
```docker-compose.sh --custom-conf files/my_custom_docker-compose.config up -d --no-recreate```

### Access your eZ Platform installation

When the containers are created, you should be able to browse to eZ Platform setup wizard by going to http://[VM_IP_ADDR]:8080/ if using vagrant and http://localhost:8080/ if running the containers on localhost 

### Setting up eZ Platform using install script

It is possible to setup a fresh installation using the install script instead of using the setup wizard. ( If using vagrant, this is done automaticly )
 - Run command : ```docker-compose -f docker-compose.yml run --rm phpfpm1 /bin/bash -c "php ezpublish/console ezplatform:install demo; php ezpublish/console cache:clear --env=prod"```

FYI : The command above assumes you have ```EZ_ENVIRONMENT=prod``` in files/docker-compose.config. If you use a different setting, adjust the ```--env=....``` parameter accordingly.
You may also substitute "demo" with "demo_clean" if you want to install ezdemo without demo data, or "clean" if only want the very basics.
 

### Varnish

These are the steps needed in order to get varnish running
- Set ```VARNISH_ENABLED=yes"```in docker-compose.config.
- Run ```docker-compose.sh up -d``` or ```docker-compose.sh up -d --no-recreate``` as usual
- Run the eZ Publish Setup Wizard
- Start the varnishprepare container in order to configure eZ Publish to use a http cache in ezpublish/config/ezpublish.yml : ```docker-compose -f docker-compose[_ubuntu].yml start varnishprepare```
  This varnishprepare container has some requirements:
  - Please note that this container must be run *after* setup wizard has been created. If you run it before SW, the ezpublish.yml is yet not generated and the varnishprepare container will abort
  - In order to inject the settings correctly in ezpublish.yml, your ezpublish.yml should not differ too much from the standard ezpublish.yml generated by the setup wizard
  - Due to the fact mentioned in previous point, this container do not support installations which has been configured using the install script.
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

And inspect the eZ Publish folder which was rsynced into the vm and is used as volume for `ezpublishvol` container:
- ```ls -al /vagrant/volumes/ezpublish/```


##### Running php-cli and mysql commands

To run php/mysql commands you'll need to start a new container which contains php-cli:
- ```vagrant ssh```
- ```docker run --rm -i -t --link ezpublishdocker_db1_1:db --dns 8.8.8.8 --dns 8.8.4.4 --volumes-from ezpublishdocker_ezpublishvol_1 --volumes-from ezpublishdocker_composercachevol_1 ezpublishdocker_phpcli /bin/bash```

If running the containers on localhost, you have to skip the ```vagrant ssh``` of course

From there you can run symfony commands like normal:
- ```php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env dev``

You can also access mysql from this container as it has the mysql client installed:
- ```mysql -uadmin --password=[mysqlpasswd] --protocol=tcp --host=db```

Mysql password is defined in files/docker-compose.config

( For other environment variables see ```env```, basically these typically comes from parent images and links )

To get out, type ```exit``` two times ;)

##### Running vagrant from windows

It is possible to run this from Windows. However, it is not possible to use synced_folder with type virtualbox (seems to be some incompatibility between virtualbox and docker's provision plugin in Vagrant or between CoreOS and Vagrant ? )
So, you need to use rsync on Windows too. In order to do this, you need rsync and ssh.
Easiest way to accomplish this is to install MinGW ( minimalist GNU for Windows ), http://sourceforge.net/projects/mingw/files/MSYS/Extension/rsync/rsync-3.0.8-1/
Download wingw-get-setup.exe and install openssh and rsync. You should then add "C:\MinGW\msys\1.0\bin" to your path and you should be all set to run "vagrant up"

If you have issues getting ssh keys to work with MinGW, this is how to fix that:

    C:\> cd C:\MinGW\msys\1.0
    C:\> mkdir home\vl\.ssh

Substitute 'C:\MinGW\msys\1.0' with your actuall MinGW installation directory.

### Tutorials

#### Installing the system using vagrant

Make a config file ( recommended, but not strictly speaking )
    ```cp files/docker-compose.config-EXAMPLE files/docker-compose.config```

Make a vagrant config file
    ```cp files/vagrant.yml-EXAMPLE to files/vagrant.yml```

Start vagrant
    ```vagrant up```

Access the eZ Platform installation.
Access the installation using the url http://33.33.33.53/



#### Installing on local host without vagrant ( requires docker and docker-compose installed locally )

Make a config file ( recommended, but not strictly speaking )
    ```cp files/docker-compose.config-EXAMPLE files/docker-compose.config```

Create the service images ( web and php images )
    ```./build.sh```

Install eZ Platform/Studio:
    ```./docker-compose_ezpinstall.sh```

Create the containers needed for running eZ Platform/Studio
    ```./docker-compose.sh up -d --no-recreate```

Run the install script
    ```docker-compose -f docker-compose.yml run --rm phpfpm1 /bin/bash -c "php ezpublish/console ezplatform:install demo; php ezpublish/console cache:clear --env=prod"```

Stop the containers:
    ```docker-compose -f docker-compose.yml stop```

Remove the containers:
    ```docker-compose -f docker-compose.yml rm -v; docker-compose -f docker-compose_ezpinstall.yml rm -v```

Remove the images:
    ```docker rmi ezsystems/web ezsystems/ezphp```

Remove the eZ Platform files:
    ```sudo rm -rf volumes/ezpublish/* volumes/mysql/*; sudo rm volumes/ezpublish/.travis.yml volumes/ezpublish/.gitignore```


#### Building the distro container

Make a config file
    ```cp files/distro_containers.config-EXAMPLE files/distro_containers.config```
    
Create the service images ( web, db and php images )
    ```./build.sh```

Create the containers
    ```./create_distro_containers.sh```

Start the containers
    ```source files/docker-compose.config; docker-compose -f docker-compose_services.yml up -d --no-recreate```

Remove all the containers
    ```
    docker-compose -f docker-compose_services.yml stop; docker-compose -f docker-compose_services.yml rm -v
    ./create_distro_containers.sh --cleanup
    ```
