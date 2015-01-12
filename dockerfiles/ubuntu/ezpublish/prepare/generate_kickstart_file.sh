#!/bin/bash

# Parameter $1 is value of EZ_KICKSTART_FROM_TEMPLATE ( could be empty )

if [ ! -f ezpublish_legacy/kickstart.ini-dist ]; then
    echo "ERROR: Could not find ezpublish_legacy/kickstart.ini-dist, did you forget to place eZ Publish in vagrant/ezpublish folder?"
    exit 1;
fi

if [ "aa$1" == "aa" ]; then
    echo "Generating kickstart.ini"

    echo "[database_choice]
Continue=true
Type=mysqli

[database_init]
#Continue=true
Server=db
Port=${DB_PORT_3306_TCP_PORT}
Database=ezp
User=admin
Password=${DB_ENV_MYSQL_PASS}
Socket=

[site_details]
Database=ezp
" > ezpublish_legacy/kickstart.ini
else
    cp $1 ezpublish_legacy/kickstart.ini

    sed -i "s@^Server=@Server=db@" ezpublish_legacy/kickstart.ini
    sed -i "s@^Port=@Port=${DB_PORT_3306_TCP_PORT}@" ezpublish_legacy/kickstart.ini
    sed -i "s@^Database=@Database=ezp@" ezpublish_legacy/kickstart.ini
    sed -i "s@^User=@User=admin@" ezpublish_legacy/kickstart.ini
    sed -i "s@^Password=@Password=${DB_ENV_MYSQL_PASS}@" ezpublish_legacy/kickstart.ini
fi
