#!/bin/bash

set -e

source ./etcd_functions

cat /supervisord-base.conf-part > /etc/supervisor/conf.d/supervisord-httpssh.conf

if [ aa$ETCD_ENABLED == "aayes" ]; then
    wait_for_etcd_to_get_online
    set_etcd_value "/ezpublish/nginx_ip" `get_container_ip`

    cat /supervisord-etcd.conf-part >> /etc/supervisor/conf.d/supervisord-httpssh.conf

fi

# Copy nginx config from [ezp_base_dir]/doc/nginx.
cp /var/www/doc/nginx/etc/nginx/sites-available/mysite.com /etc/nginx/sites-available/ezpublish
cp -a /var/www/doc/nginx/etc/nginx/ez_params.d /etc/nginx/

ln -s -f /etc/nginx/sites-available/ezpublish /etc/nginx/sites-enabled/ezpublish

# Make sure nginx forwards to php5-fpm on tcp port, not unix socket
sed -i "s@  fastcgi_pass unix:/var/run/php5-fpm.sock;@  # fastcgi_pass unix:/var/run/php5-fpm.sock;@" /etc/nginx/sites-available/ezpublish
sed -i "s@  #fastcgi_pass 127.0.0.1:9000;@  fastcgi_pass php_fpm:${PHP_FPM_PORT_9000_TCP_PORT};@" /etc/nginx/sites-available/ezpublish

# Setting environment for ezpublish ( dev/prod/behat etc )
sed -i "s@  #fastcgi_param ENVIRONMENT dev;@  fastcgi_param ENVIRONMENT ${EZ_ENVIRONMENT};@" /etc/nginx/sites-available/ezpublish

# Update port number and basedir in site-available/ezpublish
sed -i "s@%PORT%@${NGINXPORT}@" /etc/nginx/sites-available/ezpublish
sed -i "s@%BASEDIR%@${BASEDIR}@" /etc/nginx/sites-available/ezpublish

echo "fastcgi_read_timeout $FASTCGI_READ_TIMEOUT;" > /etc/nginx/conf.d/fastcgi_read_timeout.conf

if [ aa$VARNISH_ENABLED == "aayes" ]; then
    sed -i "s@  #fastcgi_param USE_HTTP_CACHE 1;@  fastcgi_param USE_HTTP_CACHE 0;@" /etc/nginx/sites-available/ezpublish
    sed -i "s@  #fastcgi_param TRUSTED_PROXIES \"%PROXY%\";@  fastcgi_param TRUSTED_PROXIES \"${DOCKER0NET}\";@" /etc/nginx/sites-available/ezpublish
fi


exec supervisord -n
