#!/bin/bash

set -e


# Copy nginx config from [ezp_base_dir]/doc/nginx
cp ${BASEDIR}/doc/nginx/etc/nginx/sites-available/mysite.com /etc/nginx/conf.d/ez.conf
cp -a ${BASEDIR}/doc/nginx/etc/nginx/ez_params.d /etc/nginx/

# Make sure nginx forwards to php5-fpm on tcp port, not unix socket
sed -i "s@  fastcgi_pass unix:/var/run/php5-fpm.sock;@  # fastcgi_pass unix:/var/run/php5-fpm.sock;@" /etc/nginx/conf.d/ez.conf
sed -i "s@  #fastcgi_pass 127.0.0.1:9000;@  fastcgi_pass php_fpm:${PHP_FPM_PORT_9000_TCP_PORT};@" /etc/nginx/conf.d/ez.conf

# Setting environment for ezpublish ( dev/prod/behat etc )
sed -i "s@  #fastcgi_param ENVIRONMENT dev;@  fastcgi_param ENVIRONMENT ${EZ_ENVIRONMENT};@" /etc/nginx/conf.d/ez.conf

# Disable asset rewrite rules if dev env
if [ "$EZ_ENVIRONMENT" == "dev" ]; then
    sed -i "s@  include ez_params.d/ez_prod_rewrite_params;@  # include ez_params.d/ez_prod_rewrite_params;@" /etc/nginx/conf.d/ez.conf
fi

# Update port number and basedir in /etc/nginx/conf.d/ez.conf
sed -i "s@%PORT%@${PORT}@" /etc/nginx/conf.d/ez.conf
sed -i "s@%BASEDIR%@${BASEDIR}@" /etc/nginx/conf.d/ez.conf

echo "fastcgi_read_timeout $FASTCGI_READ_TIMEOUT;" > /etc/nginx/conf.d/fastcgi_read_timeout.conf

if [ "$VARNISH_ENABLED" == "yes" ]; then
    sed -i "s@  #fastcgi_param USE_HTTP_CACHE 1;@  fastcgi_param USE_HTTP_CACHE 0;@" /etc/nginx/conf.d/ez.conf
    sed -i "s@  #fastcgi_param TRUSTED_PROXIES \"%PROXY%\";@  fastcgi_param TRUSTED_PROXIES \"${DOCKER0NET}\";@" /etc/nginx/conf.d/ez.conf
fi


exec /usr/sbin/nginx
#while [ 1 ]; do echo -n .; sleep 60; done
#exec /bin/bash
