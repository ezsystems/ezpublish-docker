#!/bin/bash

cd /var/www

if [ "aa$APACHE_RUN_USER" == "aa" ]; then
    APACHE_RUN_USER=www-data
fi

sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web
sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web

if [ -d ezpublish_legacy ]; then
    sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
    sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
fi

cd - > /dev/null

