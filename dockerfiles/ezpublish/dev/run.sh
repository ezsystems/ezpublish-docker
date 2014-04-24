#!/bin/bash

if [ "$EZ_KICKSTART" = "true" ]; then
	/generate_kickstart_file.sh
fi

# Fix permissions as they are wrong in case rsync is used
cd /var/www/
sudo chown -R "${APACHE_RUN_USER}":"${APACHE_RUN_GROUP}" ezpublish/{cache,logs,config} ezpublish_legacy/{design,extension,settings,var} web
sudo find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type d | sudo xargs chmod -R 775
sudo find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type f | sudo xargs chmod -R 664

# start services
exec supervisord -n
