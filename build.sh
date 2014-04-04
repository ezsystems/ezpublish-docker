#!/bin/bash

docker build -rm -t sample/apache dockerfiles/apache

docker build -rm -t sample/apache-php:prod dockerfiles/apache-php/prod
docker build -rm -t sample/apache-php:dev  dockerfiles/apache-php/dev

docker build -rm -t sample/application:dev  dockerfiles/application/dev
docker build -rm -t sample/application:prod dockerfiles/application/prod



