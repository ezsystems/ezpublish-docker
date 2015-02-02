#!/bin/bash

if [ -f files/auth.json ]; then
    cp files/auth.json dockerfiles/ezpublish/install
else
    touch dockerfiles/ezpublish/install/auth.json
fi

cp resources/setupwizard_ezstep_welcome.patch dockerfiles/ezpublish/install

# Copy kickstart template to build dir
if [ "aa$EZ_KICKSTART_FROM_TEMPLATE" != "aa" ]; then
    cp files/$EZ_KICKSTART_FROM_TEMPLATE dockerfiles/ezpublish/install/kickstart_template.ini
else
    echo "" > dockerfiles/ezpublish/install/kickstart_template.ini
fi


source files/fig.config-EXAMPLE && source files/fig.config && ${FIG_EXECUTION_PATH}fig -f fig_ezpinstall.yml up --no-recreate
