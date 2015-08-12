#!/bin/bash

export COMPOSE_PROJECT_NAME=ezpublishdocker
CONFIGFILE=files/docker-compose.config
YMLFILE="docker-compose_ezpinstall.yml"
CMDPARAMETERS="$@"

# Check for parameter "-c alternative-config.file.config"
function set_composeconfig
{
    local value
    value=0

    for i in "$@"; do
        if [ $i == "-c" ]; then
            value=1
            continue
        fi
        if [ $value == 1 ]; then
            value=0
            CONFIGFILE=$i
            echo Config file overriden. Using $CONFIGFILE instead
            continue
        fi
        CMDPARAMETERS="$CMDPARAMETERS $i"
    done
}

set_composeconfig "$@"

# Load default settings
source files/docker-compose.config-EXAMPLE

# Load custom settings
source $CONFIGFILE

if [ ! -f files/auth.json ]; then
    touch files/auth.json
fi

# Copy kickstart template to build dir
if [ "aa$EZ_KICKSTART_FROM_TEMPLATE" != "aa" ]; then
    cp files/$EZ_KICKSTART_FROM_TEMPLATE dockerfiles/ezpublish/kickstart_template.ini
else
    echo "# Kickstart file not found. Please check your kickstart settings ( like EZ_KICKSTART_FROM_TEMPLATE ) in config/docker-compose.config if you want a kickstart file " > dockerfiles/ezpublish/kickstart_template.ini
fi

# If {COMPOSE_EXECUTION_PATH} is not set and docker-compose is not in path, we'll test if it is located in /opt/bin. Needed for systemd service
if [ "$COMPOSE_EXECUTION_PATH" == "" ]; then
    if [ ! `which ${COMPOSE_EXECUTION_PATH}docker-compose > /dev/null` ]; then
        if [ -x "/opt/bin/docker-compose" ]; then
            COMPOSE_EXECUTION_PATH="/opt/bin/"
        fi
    fi
fi

if [ "$EZ_ENVIRONMENT" = "dev" ]; then
    YMLFILE="docker-compose_ezpinstall_dev.yml"
fi

${COMPOSE_EXECUTION_PATH}docker-compose -f $YMLFILE up --no-recreate

echo "Running Composer : composer --no-interaction create-project ${EZ_COMPOSERPARAM?}"
${COMPOSE_EXECUTION_PATH}docker-compose -f $YMLFILE run --rm ezpphp composer --no-interaction create-project --no-progress ${EZ_COMPOSERPARAM?};
