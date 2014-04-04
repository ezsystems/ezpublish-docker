# Symfony2 with Docker Sample

Sample Symfony2 application on Docker (production and development environment).

**NOTE:** This project requires Vagrant 1.4+.

## Installation

- Ensure you have the following tools installed on our computer:
 - Vagrant (http://vagrantup.com)
 - VirtualBox (http://www.virtualbox.org)
- Run `vagrant up`

## Building images

Use `./build.sh` in project root to build all docker images or run each command yourself.

### What's inside ?

All images are based on `ubuntu:13.10`

#### ezpublish/apache

Clean apache2 docker image.

#### ezpublish/apache-php:prod

Image based on `ezpublish/apache`.

Apache2 with php 5.5. Also installed `curl` and `composer`.

#### ezpublish/apache-php:dev

Image based on `ezpublish/apache-php:prod`.

Added `xdebug` and `webgrind`.

#### ezpublish/application:prod

Image based on `ezpublish/apache-php:prod`

Symfony2 application. Code is under `/srv/ezpublish/`.

#### ezpublish/application:dev

Image based on `ezpublish/apache-php:dev`

Image prepared to by run with mounted shared volume with application code to `/srv/ezpublish/`.


## Production

TBD

## Development environment

Running docker image.

#### 1. Default command

Default CMD starts apache (it doesn't install composer dependencies or install assets)

Inside the VM command-line run:

`docker run -p 80:80 -v /vagrant/ezpublish/:/srv/ezpublish:rw ezpublish/application:dev`

Now you have running instance of your application under `http://symfony2-docker.playground`

#### 2. /bin/bash 

If you want develop your application inside docker instance, run command in the VM command-line:

`docker run -i -t -p 80:80 -v /vagrant/ezpublish/:/srv/ezpublish:rw ezpublish/application:dev /bin/bash`

Now you should be inside docker instance. 

Next step is run apache: `service apache2 start`.

Application code is in `/srv/ezpublish/`.

## TODO

- Create docker images for databases (MySQL, NoSQL)
- Symfony2 Simple CRUDs
- Make possible to pass `TIMEZONE` to `docker build` or `docker run`
- Make possible to pas `github` to `docker build` (Required sometimes for composer ([see](https://github.com/composer/composer/issues/2366)))