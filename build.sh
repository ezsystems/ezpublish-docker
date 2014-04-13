#!/bin/bash

docker build --rm -t ezsystems/apache dockerfiles/apache/

docker build --rm -t ezsystems/apache-php:prod dockerfiles/apache-php/prod/
docker build --rm -t ezsystems/apache-php:dev  dockerfiles/apache-php/dev/

#docker build --rm -t ezsystems/ezpublish:prod dockerfiles/ezpublish/prod/
docker build --rm -t ezsystems/ezpublish:dev  dockerfiles/ezpublish/dev/



