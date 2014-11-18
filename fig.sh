#!/bin/bash

if [ -f files/auth.json ]; then
    echo bla1
    cp files/auth.json dockerfiles/ezpublish/prepare
    echo bla2
else
    touch dockerfiles/ezpublish/prepare/auth.json
fi
cp files/etcd_functions dockerfiles/etcd
cp files/etcd_functions dockerfiles/mysql
cp files/etcd_functions dockerfiles/php-fpm
cp files/etcd_functions dockerfiles/nginx

export FIG_PROJECT_NAME=ezpublishdocker

source files/fig.config

# Make a argumentlist where any "-d" is removed
for i in "$@"; do
    if [ $i != "-d" ]; then
        arglistnodetach="$arglistnodetach $i"
    fi
done

# This is a workaround for https://github.com/docker/fig/issues/540
${FIX_EXECUTION_PATH}fig -f fig_initial.yml "$@"

# We need to build etcd next so that the .deb package can be placed inside other images
if [ ! -f volumes/etcd/etcd_0.4.6_amd64.deb ]; then
    ${FIX_EXECUTION_PATH}fig -f fig_etcd.yml $arglistnodetach
fi

# Copy the etcd .deb to the dockerfile directory for images that need it
if [ ! -f dockerfiles/mysql/etcd_0.4.6_amd64.deb ]; then
    cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/mysql
    cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/php-fpm
    cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/nginx
fi

${FIX_EXECUTION_PATH}fig "$@"

