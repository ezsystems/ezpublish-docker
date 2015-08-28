#!/bin/bash

export COMPOSE_PROJECT_NAME=ezpublishdocker
CONFIGFILE=files/docker-compose.config
CMDPARAMETERS="$@"

# Check for parameter "-c alternative-config.file.config"
function set_composeconfig
{
    local value
    value=0

    CMDPARAMETERS=""

    for i in "$@"; do
        if [ "$i" == "--custom-conf" ]; then
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


# If {COMPOSE_EXECUTION_PATH} is not set and docker-compose is not in path, we'll test if it is located in /opt/bin. Needed for systemd service
if [ aa$COMPOSE_EXECUTION_PATH == "aa" ]; then
    if [ ! `which ${COMPOSE_EXECUTION_PATH}docker-compose > /dev/null` ]; then
        if [ -x "/opt/bin/docker-compose" ]; then
            COMPOSE_EXECUTION_PATH="/opt/bin/"
        fi
    fi
fi

cp -f resources/ezpublish.yml_varnishpurge.diff dockerfiles/internal/varnish_prepare/

# Make a argumentlist where any "-d" is removed
for i in $CMDPARAMETERS; do
    if [ $i != "-d" ]; then
        arglistnodetach="$arglistnodetach $i"
    fi
done

${COMPOSE_EXECUTION_PATH}docker-compose $CMDPARAMETERS
