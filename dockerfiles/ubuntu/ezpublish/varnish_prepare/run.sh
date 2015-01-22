#!/bin/bash

if [ aa$VARNISH_ENABLED == "aayes" ]; then

    VARNISH_IP=`cat /etc/hosts|grep -E '\svarnish$' | cut -f 1|head -n 1`
    echo VARNISH_IP=$VARNISH_IP
    cat /etc/hosts

    if [ -f ezpublish/config/ezpublish.yml ]; then
        # Hack : let's patch the diff in case we have installed ezdemo_site_clean ( and not ezdemo_site )
        # This is anyway a workaround until new setup wizard which supports configuring ezp with varnish is in place
        cp /ezpublish.yml_varnishpurge.diff /ezpublish.yml_varnishpurge_patched.diff
        grep "ezdemo_site_clean_group:" ezpublish/config/ezpublish.yml && perl -pi -e "s|ezdemo_site_group:|ezdemo_site_clean_group:|" /ezpublish.yml_varnishpurge_patched.diff


        # apply patch, ignore patch if already applied and do not create any .rej files
        patch -p0 -N -r - < /ezpublish.yml_varnishpurge_patched.diff

        # Inject varnish' IP in ezpublish config
        perl -pi -e "s|^(.*)purge_servers:(.*)|\1purge_servers: [http://$VARNISH_IP:80]|" ezpublish/config/ezpublish.yml

        php ezpublish/console cache:clear --env=$EZ_ENVIRONMENT
    else
        echo File do not exists : ezpublish/config/ezpublish.yml. Skipping injecting varnish IP
    fi
fi

