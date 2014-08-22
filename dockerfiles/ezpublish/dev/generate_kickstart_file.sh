#!/bin/bash

if [ ! -f ezpublish_legacy/kickstart.ini-dist ]; then
    echo "ERROR: Could not find ezpublish_legacy/kickstart.ini-dist, did you forget to place eZ Publish in vagrant/ezpublish folder?"
    exit 1;
fi


echo "Generating kickstart.ini"

echo "[database_choice]
Continue=true
Type=mysqli

[database_init]
#Continue=true
Server=${DB_PORT_3306_TCP_ADDR}
Port=${DB_PORT_3306_TCP_PORT}
Database=ezp
User=admin
Password=${DB_ENV_MYSQL_PASS}
Socket=

[site_details]
Database=ezp
" > ezpublish_legacy/kickstart.ini