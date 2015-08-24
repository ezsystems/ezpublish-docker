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

function build
{
    ./docker-compose.sh $CONFIGFILEPARAM -f docker-compose_build.yml build
}

function tag
{
    docker tag -f ${COMPOSE_PROJECT_NAME}_web:latest ezsystems/web:latest
    docker tag -f ${COMPOSE_PROJECT_NAME}_ezphp:latest ezsystems/ezphp:latest
}

set_composeconfig "$@"

# Load default settings
source files/docker-compose.config-EXAMPLE

# Load custom settings
source $CONFIGFILE

if [ $CONFIGFILE == "files/docker-compose.config" ]; then
    CONFIGFILEPARAM=""
else
    CONFIGFILEPARAM="-c $CONFIGFILE "
fi



build
tag
