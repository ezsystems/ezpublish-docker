#!/bin/bash

export FIG_PROJECT_NAME=ezpublishdocker

# Load default settings
source files/fig.config-EXAMPLE

# Load custom settings
source files/fig.config

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
    echo "# Kickstart file not found. Please check your kickstart settings ( like EZ_KICKSTART_FROM_TEMPLATE ) in config/fig.config if you want a kickstart file " > dockerfiles/ezpublish/install/kickstart_template.ini
fi

# Load default settings
source files/fig.config-EXAMPLE

# Load custom settings
source files/fig.config

# If {FIG_EXECUTION_PATH} is not set and fig is not in path, we'll test if it is located in /opt/bin. Needed for systemd service
if [ aa$FIG_EXECUTION_PATH == "aa" ]; then
    if [ ! `which ${FIG_EXECUTION_PATH}fig > /dev/null` ]; then
        if [ -x "/opt/bin/fig" ]; then
            FIG_EXECUTION_PATH="/opt/bin/"
        fi
    fi
fi

${FIG_EXECUTION_PATH}fig -f fig_ezpinstall.yml up --no-recreate
