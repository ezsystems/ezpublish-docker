#!/bin/bash

MAXTRY=10

# db container might not be ready, so let's wait for it such case
function createMysqlDatabase
{
    local DBUP
    local TRY
    DBUP=false
    TRY=1
    while [ $DBUP == "false" ]; do
        echo Contacting mysql, attempt :$TRY
        mysql -uadmin --password=$DB_ENV_MYSQL_PASS --protocol=tcp --host=db -e "CREATE DATABASE IF NOT EXISTS ezp CHARACTER SET=utf8" && DBUP="true"
        let TRY=$TRY+1
        if [ $TRY -eq $MAXTRY ]; then
            echo Max limit reached. Not able to connect to mysql
            exit 1;
        fi
        sleep 2;
    done
}

# Make sure we are within root www dir
cd /var/www/


echo `date` kickstart=$EZ_KICKSTART > /vlog.txt

# Prepare for setup wizard if requested
if [ "$EZ_KICKSTART" = "true" ]; then
  /generate_kickstart_file.sh
fi

# Dowload packages if requested
if [ "$EZ_PACKAGEURL" != "" ]; then
  /install_packages.sh
fi


echo "Setting permissions on eZ Publish folder as they might be broken if rsync is used"
sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx \
     ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var} web
sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx \
     ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var} web


echo "Re-generate symlink assets in case rsync was used so asstets added during setup wizards are reachable"
# php ezpublish/console assetic:dump --env dev
php ezpublish/console assets:install --symlink --relative --env dev
php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env dev


# Create ezp database if we intend to run setup wizard (need to be run last to make sure db is up)
if [ "$EZ_KICKSTART" = "true" ]; then
  echo "Creating database if it does not exists"
  createMysqlDatabase
fi

