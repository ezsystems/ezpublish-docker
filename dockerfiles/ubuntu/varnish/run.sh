#!/bin/bash

set -e

source ./etcd_functions

cat /supervisord-base.conf-part > /etc/supervisord.d/supervisord-varnish.ini

if [ aa$ETCD_ENABLED == "aayes" ]; then
    wait_for_etcd_to_get_online
    set_etcd_value "/ezpublish/varnish_ip" `get_container_ip`

    cat /supervisord-etcd.conf-part >> /etc/supervisor/conf.d/supervisord-varnish.ini

fi

# copy .vcl from [ezp_base_dir]/doc/varnish/vcl/varnish4.vcl if it exists, if not use fallback config
if [ -f /var/www/doc/varnish/vcl/varnish4.vcl ]; then
    sleep 2
    cp /var/www/doc/varnish/vcl/varnish4.vcl /etc/varnish/varnish4.vcl
else
    cp /varnish_config_fallback/varnish4.vcl /etc/varnish/varnish4.vcl
fi

sed -i '/\.host = "127.0.0.1";/c    .host = "nginx";' /etc/varnish/varnish4.vcl
sed -i '/acl invalidators {/a    "php_fpm";' /etc/varnish/varnish4.vcl

exec supervisord -n
