#!/bin/bash

cd /var/www

function set_permissions
{
    if [ "aa$APACHE_RUN_USER" == "aa" ]; then
        APACHE_RUN_USER=www-data
    fi

    sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web
    sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web

    if [ -d ezpublish_legacy ]; then
        sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
        sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
    fi
}

# This function is not needed on amazon ecs as we can there use links instead of updating parameters.yml
function update_parameters.yml
{
    if [ "aa$SKIP_UPDATE_PARAMETERS" == "aayes" ]; then
        exit
    fi

    if [ "aa${database_host}" != "aa" ]; then
        sed -i "s@database_host:.*@database_host: $database_host@" ezpublish/config/parameters.yml
    fi

    if [ "aa${database_name}" != "aa" ]; then
        sed -i "s@database_name:.*@database_name: $database_name@" ezpublish/config/parameters.yml
    fi

    if [ "aa${database_port}" != "aa" ]; then
        sed -i "s@database_port:.*@database_port: $database_port@" ezpublish/config/parameters.yml
    fi

    if [ "aa${database_user}" != "aa" ]; then
        sed -i "s@database_user:.*@database_user: $database_user@" ezpublish/config/parameters.yml
    fi

    if [ "aa${database_password}" != "aa" ]; then
        sed -i "s@database_password:.*@database_password: $database_password@" ezpublish/config/parameters.yml
    fi
}

set_permissions
update_parameters.yml

cd - > /dev/null

