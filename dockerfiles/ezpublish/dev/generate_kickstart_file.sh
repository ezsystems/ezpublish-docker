#!/bin/bash
if [ ! -f /.mysql_admin_created ]; then

if [ "$EZ_KICKSTART" = "1" ]; then
	/create_mysql_admin_user.sh
fi

sudo service apache2 start