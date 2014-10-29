#!/bin/bash

set -e

source ./etcd_functions

if [ aa$ETCD_ENABLED == "aayes" ]; then
    wait_for_etcd_to_get_online
    set_etcd_value "/ezpublish/db_ip" `get_container_ip`
fi

/run.sh
