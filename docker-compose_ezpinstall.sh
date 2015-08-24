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

if [ ! -f files/kickstart_template.ini ]; then
    touch files/kickstart_template.ini
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

# Unless user has provided install to use in volume folder, install from composer
if [ ! -f volumes/ezpublish/composer.json ]; then
    echo "No prior install detected in ezpublish folder, so running Composer with: composer --no-interaction create-project ${EZ_COMPOSERPARAM?}"
    ${COMPOSE_EXECUTION_PATH}docker-compose -f $YMLFILE run --rm ezphp composer --no-interaction create-project --no-progress ${EZ_COMPOSERPARAM?};
else
    echo "Prior install detected in ezpublish folder, skipp running Composer"
fi
