#!/bin/bash

cp files/auth.json dockerfiles/ezpublish/prepare
cp files/etcd_functions dockerfiles/mysql

# This is a workaround for https://github.com/docker/fig/issues/540
fig -f fig_initial.yml "$@"

fig "$@"