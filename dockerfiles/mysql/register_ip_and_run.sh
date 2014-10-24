#!/bin/bash

set -e

source ./etcd_functions

if [ aa$ETCD_ENABLED == "aayes" ]; then
    set_etcd_value "/ezpublish/db_ip" `get_container_ip`
fi

/run.sh