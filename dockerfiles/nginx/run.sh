#!/bin/bash


# copy nginx config from [ezp_base_dir]/doc/nginx
cp /var/www/doc/nginx/etc/nginx/sites-available/mysite.com /etc/nginx/sites-available/ezpublish
cp -a /var/www/doc/nginx/etc/nginx/ez_params.d /etc/nginx/

ln -s /etc/nginx/sites-available/ezpublish /etc/nginx/sites-enabled/ezpublish

# Make sure nginx forwards to php5-fpm on tcp port, not unix socket
sed -i "s@  fastcgi_pass unix:/var/run/php5-fpm.sock;@  # fastcgi_pass unix:/var/run/php5-fpm.sock;@" /etc/nginx/sites-available/ezpublish
sed -i "s@  #fastcgi_pass 127.0.0.1:9000;@  fastcgi_pass ${PHP_FPM_PORT_9000_TCP_ADDR}:${PHP_FPM_PORT_9000_TCP_PORT};@" /etc/nginx/sites-available/ezpublish

# Update port number and basedir in site-available/ezpublish
sed -i "s@%PORT%@${PORT}@" /etc/nginx/sites-available/ezpublish
sed -i "s@%BASEDIR%@${BASEDIR}@" /etc/nginx/sites-available/ezpublish


#echo "while true; do echo hello world; sleep 1; done" > /a.sh; chmod a+x /a.sh
#/a.sh
/usr/sbin/nginx
