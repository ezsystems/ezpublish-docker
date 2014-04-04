#!/bin/bash

docker build --rm -t ezpublish/apache dockerfiles/apache/

docker build --rm -t ezpublish/apache-php:prod dockerfiles/apache-php/prod/
docker build --rm -t ezpublish/apache-php:dev  dockerfiles/apache-php/dev/

#docker build --rm -t ezpublish/application:prod dockerfiles/application/prod/
docker build --rm -t ezpublish/application:dev  dockerfiles/application/dev/



