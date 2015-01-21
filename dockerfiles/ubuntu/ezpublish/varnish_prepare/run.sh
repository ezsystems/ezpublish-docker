#!/bin/bash

if [ aa$VARNISH_ENABLED == "aayes" ]; then

    VARNISH_IP=`cat /etc/hosts|grep -E '\svarnish$' | cut -f 1|head -n 1`
    echo VARNISH_IP=$VARNISH_IP
    cat /etc/hosts

    if [ -f ezpublish/config/ezpublish.yml ]; then
        # apply patch, ignore patch if already applied and do not create any .rej files
        patch -p0 -N -r - < /ezpublish.yml_varnishpurge.diff

        # Inject varnish' IP in ezpublish config
        perl -pi -e "s|^(.*)purge_servers:(.*)|\1purge_servers: [http://$VARNISH_IP:80]|" ezpublish/config/ezpublish.yml

        php ezpublish/console cache:clear --env=$EZ_ENVIRONMENT
    else
        echo File do not exists : ezpublish/config/ezpublish.yml. Skipping injecting varnish IP
    fi
fi

