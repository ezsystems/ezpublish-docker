#!/bin/bash

cd /var/www

function set_splash_screen
{
    mv /var/www/web/index.php /var/www/web/index.php.org
    echo "<html><body>Initializing</body></html>" > /var/www/web/index.php
}

function set_permissions
{
    if [ "aa$APACHE_RUN_USER" == "aa" ]; then
        APACHE_RUN_USER=www-data
    fi

    setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web
    setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web

    if [ -d ezpublish_legacy ]; then
        setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
        setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
    fi
}

function import_database
{
    # Wait 15 secs for mysql to boot up
    sleep 15
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -h db< /dbdump/ezp.sql
}

function warm_cache
{
    php ezpublish/console cache:warmup --env=$EZ_ENVIRONMENT
}

function remove_splash_screen
{
    mv /var/www/web/index.php.org /var/www/web/index.php
}

set_splash_screen
set_permissions
import_database
warm_cache
remove_splash_screen

cd - > /dev/null

