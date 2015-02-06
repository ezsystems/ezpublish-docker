#!/bin/bash

echo "Generating parameters.yml"


function generate_secret
{
    local secret
    secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32|head -n 1)
    echo $secret
}

SECRET=`generate_secret`

echo secret : $SECRET
echo dbpasswd : ${MYSQL_PASS}

cp /parameters.yml.template ezpublish/config/parameters.yml
sed -i "s@%secret%@$SECRET@" ezpublish/config/parameters.yml
sed -i "s@%dbpassword%@${MYSQL_PASS}@" ezpublish/config/parameters.yml


cat ezpublish/config/parameters.yml
