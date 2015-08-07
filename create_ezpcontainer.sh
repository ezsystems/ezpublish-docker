#!/bin/bash

set -e

# usage : ./create_ezpcontainer.sh [--skip-rebuilding-ezp] [ --target ezstudio ]
# --skip-rebuilding-ezp : Assumes ezpublish.tar.gz is already created and will not generate one using the fig_ezpinstall.sh script
# --target ezstudio : Create ezstudio containers instead of ezplatform

export FIG_PROJECT_NAME=ezpublishdocker
source files/fig_ezpcontainer.config
MAINFIG="fig_${DISTRIBUTION}.yml"
DATE=`date +%Y%m%d`
REBUILD_EZP="true"
BUILD_TARGET="platform" # Could be platform or studio

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
                -s* | --skip-rebuilding-ezp )
                    REBUILD_EZP="false"
                    ;;
                -t* | --target )
                    BUILD_TARGET="$2"
                    shift
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
    ${FIG_EXECUTION_PATH}fig -f $MAINFIG kill
    ${FIG_EXECUTION_PATH}fig -f $MAINFIG rm --force -v

    ${FIG_EXECUTION_PATH}fig -f fig_ezpdistribution.yml kill
    ${FIG_EXECUTION_PATH}fig -f fig_ezpdistribution.yml rm --force -v

    ${FIG_EXECUTION_PATH}fig -f fig_ezpmysqldata.yml kill
    ${FIG_EXECUTION_PATH}fig -f fig_ezpmysqldata.yml rm --force -v

    ${FIG_EXECUTION_PATH}fig -f fig_ezpinstall.yml kill
    ${FIG_EXECUTION_PATH}fig -f fig_ezpinstall.yml rm --force -v
    docker rmi ${FIG_PROJECT_NAME}_ezpinstall || /bin/true

    docker rmi ${FIG_PROJECT_NAME}_ezpdistribution:latest || /bin/true
    docker rmi ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_distribution:${DOCKER_BUILDVER} || /bin/true
    docker rmi ${FIG_PROJECT_NAME}_ezpmysqldata:latest || /bin/true
    docker rmi ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_mysqldata:${DOCKER_BUILDVER} || /bin/true


    if [ $REBUILD_EZP == "true" ]; then
        sudo rm -Rf volumes/mysql/*
        sudo rm -Rf volumes/ezpublish/*
    fi
    rm dockerfiles/ezpublish/distribution/ezpublish.tar.gz || /bin/true
}

function install_ezpublish
{
    if [ $REBUILD_EZP == "true" ]; then
        ./fig_ezpinstall.sh -c files/fig-${BUILD_TARGET}.config
    fi
}

function run_installscript
{
    #Start service containers and wait some seconds for mysql to get running
    ${FIG_EXECUTION_PATH}fig -f $MAINFIG up -d # We must call "up" before "run", or else volumes definitions in .yml will not be treated correctly ( will mount all volumes in vfs/ folder ) ( must be a fig bug )
    ${FIG_EXECUTION_PATH}fig -f $MAINFIG run --rm phpcli /bin/bash -c "sleep 12"

    if [ $REBUILD_EZP == "true" ]; then
        #docker run --rm --link ezpublishdocker_db1_1:db --volumes-from ezpublishdocker_ezpublishvol_1 --volumes-from ezpublishdocker_composercachevol_1 ezpublishdocker_phpcli /bin/bash -c "php ezpublish/console ezplatform:install demo; php ezpublish/console cache:clear --env=prod
        if [ $BUILD_TARGET == "ezplatform" ]; then
            ${FIG_EXECUTION_PATH}fig -f $MAINFIG run --rm phpcli /bin/bash -c "php ezpublish/console ezplatform:install demo; php ezpublish/console cache:clear --env=prod"
        fi
        if [ $BUILD_TARGET == "ezstudio" ]; then
            ${FIG_EXECUTION_PATH}fig -f $MAINFIG run --rm phpcli /bin/bash -c "php ezpublish/console --env=prod ezplatform:install studio; php ezpublish/console cache:clear --env=prod"
        fi
    fi
}

function warm_cache
{
    ${FIG_EXECUTION_PATH}fig -f $MAINFIG run --rm phpcli /bin/bash -c "php ezpublish/console cache:warmup --env=prod"
}

function create_distribution_tarball
{
    sudo tar -czf dockerfiles/ezpublish/distribution/ezpublish.tar.gz --directory volumes/ezpublish .
    sudo chown `whoami`: dockerfiles/ezpublish/distribution/ezpublish.tar.gz
}

function create_distribution_container
{
    fig -f fig_ezpdistribution.yml up -d
}

function push_distribution_container
{
    #docker tag -f ezpublishdocker_ezpdistribution:latest ${DOCKER_REPOSITORY}/vidarl/ezpublish_distribution:master$DATE
    docker tag -f ezpublishdocker_ezpdistribution:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_distribution:${DOCKER_BUILDVER}
    #docker push ${DOCKER_REPOSITORY}/vidarl/ezpublish_distribution:master$DATE
    docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_distribution:${DOCKER_BUILDVER}
}

function create_mysql_tarball
{
    ${FIG_EXECUTION_PATH}fig -f $MAINFIG run phpcli /bin/bash -c "mysqldump -u admin -p${MYSQL_PASS} -h db --databases ezp > /tmp/ezp.sql"
    docker cp ${FIG_PROJECT_NAME}_phpcli_run_1:/tmp/ezp.sql dockerfiles/ezpublish/mysqldata
    docker rm ${FIG_PROJECT_NAME}_phpcli_run_1
}

function create_mysql_container
{
    fig -f fig_ezpmysqldata.yml up -d
}

function push_mysql_container
{
    #docker tag -f ezpublishdocker_ezpmysqldata:latest ${DOCKER_REPOSITORY}/vidarl/ezpublish_mysqldata:master$DATE
    docker tag -f ezpublishdocker_ezpmysqldata:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_mysqldata:${DOCKER_BUILDVER}
    #docker push ${DOCKER_REPOSITORY}/vidarl/ezpublish_mysqldata:master$DATE
    docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/${BUILD_TARGET}_mysqldata:${DOCKER_BUILDVER}
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
