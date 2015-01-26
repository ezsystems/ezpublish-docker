#!/bin/bash

if [ aa$SOLR_ENABLED == "aayes" ]; then

    if [ -f ezpublish/config/ezpublish.yml ]; then
        # Detect if we have already configured solr in this ezp installation
        ALREADY_CONFIGURED=true
        grep -E "^.*engine: legacy$" ezpublish/config/ezpublish.yml && ALREADY_CONFIGURED=false

        if [ $ALREADY_CONFIGURED == "true" ]; then
            echo Solr engine already configured in this installation.
            exit
        fi

        # Added solr bundle to EzPublishKernel
        # apply patch, ignore patch if already applied and do not create any .rej files
        patch -p0 -N -r - < /ezpublishkernel.php_solrbundle.patch

        # Change to use solr engine
        perl -pi -e "s|^(.*)engine: legacy$|\1engine: legacy_solr|" ezpublish/config/ezpublish.yml

        # Set solr host in parameters.yml
        # Temporary hackas parameters.yml created by SW is not very nice to work with. Let's extract Secret and re-generate it
        perl -pi -e "s|(^.*)secret: ([0-9a-zA-Z]*),.*$|\2|" ezpublish/config/parameters.yml ; EZPSECRET=`cat ezpublish/config/parameters.yml`
        cp ezpublish/config/parameters.yml.dist ezpublish/config/parameters.yml
        # insert secret again in new parameters.yml
        perl -pi -e "s|(^.*secret:)(.*)|\1 $EZPSECRET|" ezpublish/config/parameters.yml
        # Now, add solr_server setting
        echo "    ezpublish.solr_server: http://solr:8983/" >>ezpublish/config/parameters.yml

        echo clearing cache
        php ezpublish/console cache:clear --env=$EZ_ENVIRONMENT

        echo indexing
        php ezpublish/console ezpublish:solr_create_index
        echo done indexing
    else
        echo File do not exists : ezpublish/config/ezpublish.yml. Setup wizard not finished? Aborting setting up eZ Publish to use Solr engine
    fi
fi

