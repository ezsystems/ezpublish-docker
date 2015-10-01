#!/bin/bash

# Script accepts the following environment variable:
# - EZ_KICKSTART ( "true" or "false" )
# - EZ_KICKSTART_FROM_TEMPLATE ( template file )
#   Note that the value of this setting passed on to this script is the filename outside the container. Inside the container, the actuall file will always be named /kickstart_template.ini
#   Therefore, the value of this setting will be rewritten internally in the script
#
# Parameters can also be given as options, in the same order:
# ./run.sh [ EZ_KICKSTART ] [ EZ_KICKSTART_FROM_TEMPLATE ]

function parseCommandlineOptions
{
    if [ "$1" != "" ]; then
        EZ_KICKSTART=$1
    fi
    if [ "$2" != "" ]; then
        EZ_KICKSTART_FROM_TEMPLATE="/kickstart_template.ini"
    fi

    if [ "$APACHE_RUN_USER" == "" ]; then
        APACHE_RUN_USER=www-data
    fi
}

parseCommandlineOptions $1 $2


# Prepare for setup wizard if requested
if [ "$EZ_KICKSTART" = "true" ]; then
  /generate_kickstart_file.sh $EZ_KICKSTART_FROM_TEMPLATE
fi

/generate_parameters_file.sh


echo "Setting permissions on eZ Publish folder as they might be broken if rsync is used"
setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web
setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web

if [ -d ezpublish_legacy ]; then
    setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
    setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
fi

echo "Clear cache after parameters where updated"
php ezpublish/console cache:clear --env $EZ_ENVIRONMENT

if [ "$EZ_ENVIRONMENT" != "dev" ]; then
    echo "Re-generate symlink assets in case rsync was used so asstets added during setup wizards are reachable"
    php ezpublish/console assetic:dump --env $EZ_ENVIRONMENT
fi

php ezpublish/console assets:install --symlink --relative --env $EZ_ENVIRONMENT
if [ -d ezpublish_legacy ]; then
    php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env $EZ_ENVIRONMENT
fi

# Start php-fpm
exec /usr/sbin/php5-fpm
