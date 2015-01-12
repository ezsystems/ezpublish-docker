#!/bin/bash

set -e

source ./etcd_functions

wait_for_etcd_to_get_online

while [ 1 ]; do
    sleep 1
    phpfpmip=`get_etcd_value "/ezpublish/phpfpm_ip"`
    replace_ip_in_hosts $phpfpmip php_fpm

    # Need to send HUP to nginx, or else it will not re-resolve "php_fpm"
    kill -HUP `cat /var/run/nginx.pid`

    newip=`etcdctl watch /ezpublish/phpfpm_ip`

    echo `date` : Nginx has changed IP, new IP is $newip
done;
