#!/bin/bash

if [ ! -f /var/www/ezpublish_legacy/kickstart.ini-dist ]; then
    echo "ERROR: Could not find /var/www/ezpublish_legacy/kickstart.ini-dist, did you forget to place eZ Publish in vagrant folder?"
    exit 1;
fi

echo "[database_choice]
Continue=true
Type=mysqli

[database_init]
#Continue=true
Server=${DB_PORT_3306_TCP_ADDR}
Port=${DB_PORT_3306_TCP_PORT}
Database=test
User=admin
Password=${DB_ENV_MYSQL_PASS}
Socket=


[site_details]
Database=test
" > /var/www/ezpublish_legacy/kickstart.ini