#!/bin/bash

set -e

source ./etcd_functions

wait_for_etcd_to_get_online

while [ 1 ]; do
    sleep 1
    nginxip=`get_etcd_value "/ezpublish/nginx_ip"`
    replace_ip_in_hosts $nginxip backend-host

    # Need to send HUP to nginx, or else it will not re-resolve "php_fpm"
    kill -HUP `cat /var/run/varnishd.pid`

    newip=`etcdctl watch /ezpublish/nginx_ip`

    echo `date` : Nginx has changed IP, new IP is $newip
done;
