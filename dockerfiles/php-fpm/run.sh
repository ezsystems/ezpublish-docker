#!/bin/bash

set -e

source ./etcd_functions

cat /supervisord-base.conf-part > /etc/supervisor/conf.d/supervisord-httpssh.conf

if [ aa$ETCD_ENABLED == "aayes" ]; then
    wait_for_etcd_to_get_online
    set_etcd_value "/ezpublish/phpfpm_ip" `get_container_ip`

    cat /supervisord-etcd.conf-part >> /etc/supervisor/conf.d/supervisord-httpssh.conf

fi


exec supervisord -n
