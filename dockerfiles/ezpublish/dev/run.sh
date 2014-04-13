#!/bin/bash

if [ "$EZ_KICKSTART" = "true" ]; then
	/generate_kickstart_file.sh
fi

/usr/sbin/apache2 -D FOREGROUND
#sudo service apache2 start