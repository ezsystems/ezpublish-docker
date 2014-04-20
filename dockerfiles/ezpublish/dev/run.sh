#!/bin/bash

if [ "$EZ_KICKSTART" = "true" ]; then
	/generate_kickstart_file.sh
fi

exec supervisord -n
