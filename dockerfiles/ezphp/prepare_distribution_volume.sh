#!/bin/bash

# Let's try to connect to db for 2 minutes ( 24 * 5 sec intervalls )
MAXTRY=24

cd /var/www


function prevent_multiple_execuition
{
    if [ -f /already_run.txt ]; then
        echo "Script has already been executed. Bailling out"
        exit
    fi
    touch /already_run.txt
}


# $1 is description
function set_splash_screen
{
    if [ ! -f /var/www/web/index.php.org ]; then
        mv /var/www/web/index.php /var/www/web/index.php.org
    fi
    echo "<html><body>$1</body></html>" > /var/www/web/index.php
}

function remove_splash_screen
{
    mv /var/www/web/index.php.org /var/www/web/index.php
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
    local DBUP
    local TRY
    DBUP=false
    TRY=1
    while [ $DBUP == "false" ]; do
        echo Contacting mysql, attempt :$TRY
        set_splash_screen "Importing database"
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -h db< /dbdump/ezp.sql && DBUP="true"
        if [ $DBUP == "false" ]; then
            set_splash_screen "Attempt $TRY failed. Waiting for db connection"
        fi
        let TRY=$TRY+1
        if [ $TRY -eq $MAXTRY ]; then
            echo Max limit reached. Not able to connect to mysql
            rm /already_run.txt
            exit 1;
        fi
        sleep 5;
    done
}

function warm_cache
{
    php ezpublish/console cache:warmup --env=$EZ_ENVIRONMENT
}

prevent_multiple_execuition
set_splash_screen "Initializing"
set_permissions
set_splash_screen "Waiting for db connection"
import_database
set_splash_screen "Warming cache"
warm_cache
remove_splash_screen

cd - > /dev/null

