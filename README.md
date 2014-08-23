# eZ Publish5 in Docker

[WIP]eZ Publish installed in docker containers.


## Project goal

This project if done right replaces our current puppet and ansible scripts (parts might make sense to use here!).
In addition it will cover additional use cases with time, all of them being:

1.  Create a set of official containers/scripts for use for
 1.  Testing (QA, Support, Dev)
 2.  Sprint / Release Demo (PS, Sales, PM)
 3.  Production (internal Ops, but potentially also partners)
2.  Add additional containers for the different platforms we support to be able to automate Behat (BDD) testing across a wide range of platforms and combinations.

Technical goal is to eventually set up the containers in cluster mode, but for testing needs it should support being
setup in single mode as well. For cluster mode it first needs to be able to do that inside one vm, second step is being
able to spread the load across several hosts (technology choice needed here, this field is currently WIP). For containers
needed see [below](#docker-images).

## Installation

- Ensure you have the following tools installed on our computer:
 - Vagrant (http://vagrantup.com)
 - VirtualBox (http://www.virtualbox.org) **NOTE:** Requires Vagrant 1.6.
- Run `vagrant up`

#### Known issue
Assets needs to be generated after setup wizard is done, this might be eZ Publish issue with dev envirment.

To fix we need to do a 2 level inception getting inside vm and then ezpublish container, as that is difficult we just enter bash of a identical one with same eZ Publish volumen attached and same database container linked:
- ```vagrant ssh```
- ```docker run -i --link db-1:db -v '/vagrant/ezpublish/:/var/www:rw' -t ezsystems/ezpublish:dev /bin/bash```
- ```cd /var/www```
- ```php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env dev```

That should be it, ```exit``` 2 times to get back to your command line!


## Building images

Docker images are buildt and started (run) by Vagrant (see VagrantFile), however for manual build either use
the out of date `./build.sh` in project root to build all docker images or run each command yourself.

## What's inside ?

Host machine is running CoreOS allowing us to not have to maintain the host (autoupdate) and allowing us to
take advantage of its clustering cababilities in the future.

All container images are currently based on `ubuntu:14.04`

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

#### ezpublish/apache

Clean apache2 docker image.

#### ezpublish/apache-php:prod

Image based on `ezpublish/apache`.

Apache2 with php 5.5. Also installed `curl` and `composer`.

#### ezpublish/apache-php:dev

Image based on `ezpublish/apache-php:prod`.

Added `xdebug` and `webgrind`.

#### ezpublish/application:prod

!! currently not in use, ezpublish/application:dev is used instead.
Image based on `ezpublish/apache-php:prod`

Symfony2 application. Code is under `/srv/ezpublish/`.

#### ezpublish/application:dev

Image based on `ezpublish/apache-php:dev`

Image prepared to by run with mounted shared volume with application code to `/srv/ezpublish/`.
