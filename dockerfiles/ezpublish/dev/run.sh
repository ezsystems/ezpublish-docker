#!/bin/bash

# Make sure we are within root www dir
cd /var/www/

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

echo "Generate assets for dev env, otherwise they will be missing"
php ezpublish/console assetic:dump --env dev


# Create ezp database if we intend to run setup wizard (need to be run last to make sure db is up)
if [ "$EZ_KICKSTART" = "true" ]; then
  echo "Creating database if it does not exists"
  mysql -uadmin --password=$DB_ENV_MYSQL_PASS --protocol=tcp --host=$DB_PORT_3306_TCP_ADDR -e "CREATE DATABASE IF NOT EXISTS ezp CHARACTER SET=utf8"
fi


# start services
exec supervisord -n
