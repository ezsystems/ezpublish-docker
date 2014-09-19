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

eZ Publish is placed in .vagrant/ezpublish as mounted by Vagrant on boot, this is used as volume for all
containers that need access to it.

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
 - FS: NFS|GridFS|..  (services like S3 might not need a continer, but could have a contianer acting as proxy)

**Note** We should take advantage of offical images from Docker as much as possible, however they now use Debian
as it takes less space then Ubuntu, and for lowest space use (and memory?) base images should be the same across
all our offical images.

And development mode or not should probably rather be a global parameter then special images.

However right now following images exists:

## Installation

NB: This section reflects current status with images not reflecting spec above!

- Ensure you have the following tools installed on our computer:
 - Vagrant 1.6+ (http://vagrantup.com)
 - VirtualBox 4.3.12+ (http://www.virtualbox.org)
- Put your eZ Publish directly inside "ezpublish/" directory, or symlink it there (overwriting the folder)
- TODO: It is currently not supported to provide database dump, only clean install is currently supported!
- Run `vagrant up`

When this is done you should be able to browse to eZ Publish setup wizard by going to http://localhost/:8080

#### SSH

##### VM

To enter virual machine:
- ```vagrant ssh```

From there you can check running containers:
- ```docker ps```

And inspect the eZ Publish folder which was rsynced into the vm and is used as volume for eZ Publish cotainer:
- ```ls -al /vagrant/ezpublish/```


##### Container

To run php/mysql commands you'll need to get inside vm & the ezpublish container. As that is
difficult we just enter bash of a identical container with same eZ Publish volumen attached & database container linked:
- ```vagrant ssh```
- ```docker run -i --link db-1:db -v '/vagrant/ezpublish/:/var/www:rw' -t ezsystems/ezpublish:dev /bin/bash```

From there you can run symfony commands like normal:
- ```cd /var/www```
- ```php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env dev``

You can also access mysql from this contianer as it has client installed:
- ```mysql -uadmin --password=$DB_ENV_MYSQL_PASS --protocol=tcp --host=$DB_PORT_3306_TCP_ADDR```

( For other environment variables see ```env```, basically these typically comes from parent images and links )

To get out, type ```exit``` two times ;)



