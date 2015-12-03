#!/bin/bash

if [ aa$VARNISH_ENABLED == "aayes" ]; then

    VARNISH_IP=`cat /etc/hosts|grep -E '\svarnish$' | cut -f 1|head -n 1`
    echo VARNISH_IP=$VARNISH_IP

    if [ -f app/config/ezplatform.yml ]; then
        # Hack : let's patch the diff in case we have installed ezdemo_site_clean ( and not ezdemo_site )
        # This is a workaround until config is injectable for http cache settings.
        cp /ezpublish.yml_varnishpurge.diff /ezpublish.yml_varnishpurge_patched.diff
        grep "ezdemo_site_clean_group:" app/config/ezplatform.yml && perl -pi -e "s|ezdemo_site_group:|ezdemo_site_clean_group:|" /ezpublish.yml_varnishpurge_patched.diff


        # apply patch, ignore patch if already applied and do not create any .rej files
        patch -p0 -N -r - < /ezpublish.yml_varnishpurge_patched.diff

        # Inject varnish' IP in ezpublish config
        perl -pi -e "s|^(.*)purge_servers:(.*)|\1purge_servers: [http://$VARNISH_IP:80]|" app/config/ezplatform.yml

        php app/console cache:clear --env=$EZ_ENVIRONMENT
    else
        echo File do not exists : app/config/ezplatform.yml. Skipping injecting varnish IP
    fi
fi

