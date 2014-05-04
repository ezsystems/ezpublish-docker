#!/bin/bash

# Make sure we are within root www dir
cd /var/www/

# Prepare for setup wizard if requested
if [ "$EZ_KICKSTART" = "true" ]; then
	/generate_kickstart_file.sh
fi

# Dowload packages if requested
if [ "$PACKAGEURL" != "" ]; then
	/install_packages.sh
fi

# Fix permissions as they are wrong in case rsync is used
sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx \
     ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var} web
sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx \
     ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var} web

# start services
exec supervisord -n
