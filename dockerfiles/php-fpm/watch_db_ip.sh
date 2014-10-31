#!/bin/bash

set -e

source ./etcd_functions

wait_for_etcd_to_get_online

while [ 1 ]; do
    sleep 1
    dbip=`get_etcd_value "/ezpublish/db_ip"`
    replace_ip_in_hosts $dbip db

    newip=`etcdctl watch /ezpublish/db_ip`

    echo `date` : DB has changed IP, new IP is $newip
done;
