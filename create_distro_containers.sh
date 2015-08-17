#!/bin/bash

set -e

# usage : ./create_distro_containers.sh [--skip-rebuilding-ezp] [ --target ezstudio ]
# --push : Pushes the created images to a repository
# --skip-rebuilding-ezp : Assumes ezpublish.tar.gz is already created and will not generate one using the fig_ezpinstall.sh script
# --target ezstudio : Create ezstudio containers instead of ezplatform

export COMPOSE_PROJECT_NAME=ezpublishdocker
source files/distro_containers.config
MAINCOMPOSE="docker-compose.yml"
DATE=`date +%Y%m%d`
PUSH="false"
REBUILD_EZP="true"
BUILD_TARGET="ezplatform" # Could be "ezplatform" or "ezstudio"
ONLYCLEANUP="false"

function parse_commandline_arguments
{
    # Based on http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash, comment by Shane Day answered Jul 1 '14 at 1:20
    while [ -n "$1" ]; do
        # Copy so we can modify it (can't modify $1)
        OPT="$1"
        # Detect argument termination
        if [ x"$OPT" = x"--" ]; then
            shift
            for OPT ; do
                REMAINS="$REMAINS \"$OPT\""
            done
            break
        fi
        # Parse current opt
        while [ x"$OPT" != x"-" ] ; do
            case "$OPT" in
                # Handle --flag=value opts like this
#                -c=* | --config=* )
#                    CONFIGFILE="${OPT#*=}"
#                    shift
#                    ;;
#                # and --flag value opts like this
#                -c* | --config )
#                    CONFIGFILE="$2"
#                    shift
#                    ;;
#                -f* | --force )
#                    FORCE=true
#                    ;;
                -p* | --push )
                    PUSH="true"
                    ;;
                -s* | --skip-rebuilding-ezp )
                    REBUILD_EZP="false"
                    ;;
                -t* | --target )
                    BUILD_TARGET="$2"
                    shift
                    ;;
                -z* | --cleanup )
                    ONLYCLEANUP="true"
                    ;;
                # Anything unknown is recorded for later
                * )
                    REMAINS="$REMAINS \"$OPT\""
                    break
                    ;;
            esac
            # Check for multiple short options
            # NOTICE: be sure to update this pattern to match valid options
            NEXTOPT="${OPT#-[st]}" # try removing single short opt
            if [ x"$OPT" != x"$NEXTOPT" ] ; then
                OPT="-$NEXTOPT"  # multiple short opts, keep going
            else
                break  # long form, exit inner loop
            fi
        done
        # Done with that param. move to next
        shift
    done
    # Set the non-parameters back into the positional parameters ($1 $2 ..)
    eval set -- $REMAINS

    if [ "$BUILD_TARGET" != "ezstudio" ] && [ "$BUILD_TARGET" != "ezplatform" ] ; then
        echo "Invalid target : $BUILD_TARGET"
        exit
    fi
    echo "REBUILD_EZP=$REBUILD_EZP"
    echo "BUILD_TARGET=$BUILD_TARGET"
}

function prepare
{
    ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE kill
    ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE rm --force -v

    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_distribution.yml kill
    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_distribution.yml rm --force -v

    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_databasedump.yml kill
    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_databasedump.yml rm --force -v

    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_ezpinstall.yml kill
    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_ezpinstall.yml rm --force -v
    docker rmi ${COMPOSE_PROJECT_NAME}_ezpinstall || /bin/true

    docker rmi ${COMPOSE_PROJECT_NAME}_distribution:latest || /bin/true
    docker rmi ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_distribution:${DOCKER_BUILDVER} || /bin/true
    docker rmi ${COMPOSE_PROJECT_NAME}_databasedump:latest || /bin/true
    docker rmi ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_databasedump:${DOCKER_BUILDVER} || /bin/true

    docker rmi ${COMPOSE_PROJECT_NAME}_ezphp || /bin/true
    docker rmi ${COMPOSE_PROJECT_NAME}_web1 || /bin/true
    docker rmi ${COMPOSE_PROJECT_NAME}_db1 || /bin/true
    docker rmi ${COMPOSE_PROJECT_NAME}_phpfpm1 || /bin/true


    if [ $REBUILD_EZP == "true" ]; then
        sudo rm -rf volumes/ezpublish/* volumes/mysql/*; sudo rm volumes/ezpublish/.travis.yml volumes/ezpublish/.gitignore || /bin/true
    fi
    rm -f dockerfiles/ezpublish/distribution/ezpublish.tar.gz

    if [ $ONLYCLEANUP == "true" ]; then
        echo exiting
        exit
    fi
}

function install_ezpublish
{
    if [ $REBUILD_EZP == "true" ]; then
#        ./docker-compose_ezpinstall.sh -c files/docker-compose-${BUILD_TARGET}.config #FIXME : let config file be a parameter
        ./docker-compose_ezpinstall.sh
    else
        # Workaround since ezphp container is not defined in docker-compose.yml
        YMLFILE="docker-compose_ezpinstall.yml"
        if [ "$EZ_ENVIRONMENT" = "dev" ]; then
            YMLFILE="docker-compose_ezpinstall_dev.yml"
        fi
        ${COMPOSE_EXECUTION_PATH}docker-compose -f $YMLFILE build
    fi
}

function run_installscript
{
    #Start service containers and wait some seconds for mysql to get running
    #FIXME : can be removed now?
    ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE up -d # We must call "up" before "run", or else volumes definitions in .yml will not be treated correctly ( will mount all volumes in vfs/ folder ) ( must be a docker-compose bug )
    sleep 12

    if [ $REBUILD_EZP == "true" ]; then
        if [ $BUILD_TARGET == "ezplatform" ]; then
            ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE run --rm phpfpm1 /bin/bash -c "php ezpublish/console ezplatform:install demo; php ezpublish/console cache:clear --env=prod"
        fi
        if [ $BUILD_TARGET == "ezstudio" ]; then
            ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE run --rm phpfpm1 /bin/bash -c "php ezpublish/console --env=prod ezplatform:install studio; php ezpublish/console cache:clear --env=prod"
        fi
    fi
}

function warm_cache
{
    ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE run --rm phpfpm1 /bin/bash -c "php ezpublish/console cache:warmup --env=prod"
}

function create_distribution_tarball
{
    sudo tar -czf dockerfiles/distribution/ezpublish.tar.gz --directory volumes/ezpublish .
    sudo chown `whoami`: dockerfiles/distribution/ezpublish.tar.gz
}

function create_distribution_container
{
    docker-compose -f docker-compose_distribution.yml up -d
}

function tag_distribution_container
{
    docker tag -f ezpublishdocker_distribution:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_distribution:${DOCKER_BUILDVER}
}

function push_distribution_container
{
    if [ $PUSH == "true" ]; then
        docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_distribution:${DOCKER_BUILDVER}
    fi
}

function create_mysql_tarball
{
    ${COMPOSE_EXECUTION_PATH}docker-compose -f $MAINCOMPOSE run phpfpm1 /bin/bash -c "mysqldump -u ezp -p${MYSQL_PASSWORD} -h db --databases ezp > /tmp/ezp.sql"
    docker cp ${COMPOSE_PROJECT_NAME}_phpfpm1_run_1:/tmp/ezp.sql dockerfiles/databasedump
    docker rm ${COMPOSE_PROJECT_NAME}_phpfpm1_run_1
}

function create_mysql_container
{
    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_databasedump.yml up -d
}

function tag_mysql_container
{
    docker tag -f ezpublishdocker_databasedump:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_databasedump:${DOCKER_BUILDVER}
}

function push_mysql_container
{
    if [ $PUSH == "true" ]; then
        docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_mysqldata:${DOCKER_BUILDVER}
    fi
}

function create_initialize_container
{
    ${COMPOSE_EXECUTION_PATH}docker-compose -f docker-compose_initialize.yml up -d
}

echo parse_commandline_arguments
parse_commandline_arguments "$@"

echo Prepare:
prepare

echo install_ezpublish:
install_ezpublish

echo run_installscript:
run_installscript

echo warm_cache:
warm_cache

echo create_distribution_tarball
create_distribution_tarball

echo create_distribution_container
create_distribution_container

echo push_distribution_container
push_distribution_container

echo create_mysql_tarball
create_mysql_tarball

echo create_mysql_container
create_mysql_container

echo push_mysql_container
push_mysql_container
