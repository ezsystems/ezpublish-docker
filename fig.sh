#!/bin/bash

cp files/auth.json dockerfiles/ezpublish/prepare
cp files/etcd_functions dockerfiles/etcd
cp files/etcd_functions dockerfiles/mysql
cp files/etcd_functions dockerfiles/php-fpm
cp files/etcd_functions dockerfiles/nginx

# This is a workaround for https://github.com/docker/fig/issues/540
fig -f fig_initial.yml "$@"

# We need to build etcd next so that the .deb package can be placed inside other images
if [ ! -f volumes/etcd/etcd_0.4.6_amd64.deb ]; then
    fig -f fig_etcd.yml "$@"
fi

# Copy the etcd .deb to the dockerfile directory for images that need it
if [ ! -f dockerfiles/mysql/etcd_0.4.6_amd64.deb ]; then
    cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/mysql
    cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/php-fpm
    cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/nginx
fi

fig "$@"
