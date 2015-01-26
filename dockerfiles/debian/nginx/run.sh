#!/bin/bash

set -e


# copy nginx config from [ezp_base_dir]/doc/nginx if it exists, if not use fallback config
if [ -d /var/www/doc/nginx/etc/nginx/sites-available ]; then
    sleep 2
    cp /var/www/doc/nginx/etc/nginx/sites-available/mysite.com /etc/nginx/sites-available/ezpublish
    cp -a /var/www/doc/nginx/etc/nginx/ez_params.d /etc/nginx/
else
    cp /ezpublish_config_fallback/nginx/etc/nginx/sites-available/mysite.com /etc/nginx/sites-available/ezpublish
    cp -a /ezpublish_config_fallback/nginx/etc/nginx/ez_params.d /etc/nginx/
fi

ln -s -f /etc/nginx/sites-available/ezpublish /etc/nginx/sites-enabled/ezpublish

# Make sure nginx forwards to php5-fpm on tcp port, not unix socket
sed -i "s@  fastcgi_pass unix:/var/run/php5-fpm.sock;@  # fastcgi_pass unix:/var/run/php5-fpm.sock;@" /etc/nginx/sites-available/ezpublish
sed -i "s@  #fastcgi_pass 127.0.0.1:9000;@  fastcgi_pass php_fpm:${PHP_FPM_PORT_9000_TCP_PORT};@" /etc/nginx/sites-available/ezpublish

# Setting environment for ezpublish ( dev/prod/behat etc )
sed -i "s@  #fastcgi_param ENVIRONMENT dev;@  fastcgi_param ENVIRONMENT ${EZ_ENVIRONMENT};@" /etc/nginx/sites-available/ezpublish

# Update port number and basedir in site-available/ezpublish
sed -i "s@%PORT%@${PORT}@" /etc/nginx/sites-available/ezpublish
sed -i "s@%BASEDIR%@${BASEDIR}@" /etc/nginx/sites-available/ezpublish

echo "fastcgi_read_timeout $FASTCGI_READ_TIMEOUT;" > /etc/nginx/conf.d/fastcgi_read_timeout.conf

if [ aa$VARNISH_ENABLED == "aayes" ]; then
    sed -i "s@  #fastcgi_param USE_HTTP_CACHE 1;@  fastcgi_param USE_HTTP_CACHE 0;@" /etc/nginx/sites-available/ezpublish
    sed -i "s@  #fastcgi_param TRUSTED_PROXIES \"%PROXY%\";@  fastcgi_param TRUSTED_PROXIES \"${DOCKER0NET}\";@" /etc/nginx/sites-available/ezpublish
fi


exec /usr/sbin/nginx
#while [ 1 ]; do echo -n .; sleep 60; done
#exec /bin/bash
