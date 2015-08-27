#!/bin/bash

echo "Re-configuring parameters.yml"


function generate_secret
{
    local secret
    secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32|head -n 1)
    echo $secret
}

SECRET=`generate_secret`

sed -i "s@secret:.*@secret: $SECRET@" ezpublish/config/parameters.yml
sed -i "s@database_driver:.*@database_driver: pdo_mysql@" ezpublish/config/parameters.yml
sed -i "s@database_port:.*@database_port: $DB_PORT_3306_TCP_PORT@" ezpublish/config/parameters.yml
sed -i "s@database_host:.*@database_host: db@" ezpublish/config/parameters.yml
sed -i "s@database_name:.*@database_name: ezp@" ezpublish/config/parameters.yml
sed -i "s@database_user:.*@database_user: ezp@" ezpublish/config/parameters.yml
sed -i "s@database_password:.*@database_password: $MYSQL_PASSWORD@" ezpublish/config/parameters.yml



cat ezpublish/config/parameters.yml
