#!/bin/bash

# Script accepts the following environment variable:
# - EZ_KICKSTART ( "true" or "false" )
# - EZ_PACKAGEURL ( url, pointing to url where packages are located )
# - EZ_INSTALLTYPE ( "composer" )
# - EZ_COMPOSERVERSION ( What version of eZ Publish to install using composer )
# - EZ_COMPOSERREPOSITORYURL ( Url to composer repository which should be used )
#
# Parameters can also be given as options, in the same order:
# ./run.sh [ EZ_KICKSTART ] [ EZ_PACKAGEURL ] ....

MAXTRY=10

function parseCommandlineOptions
{
    if [ "aa$1" != "aa" ]; then
        EZ_KICKSTART=$1
    fi
    if [ "aa$2" != "aa" ]; then
        EZ_PACKAGEURL=$2
        export EZ_PACKAGEURL
    fi
    if [ "aa$3" != "aa" ]; then
        EZ_INSTALLTYPE=$3
    fi
    if [ "aa$4" != "aa" ]; then
        EZ_COMPOSERVERSION=$4
    fi
    if [ "aa$5" != "aa" ]; then
        EZ_COMPOSERREPOSITORYURL=$5
    fi


    if [ "aa$APACHE_RUN_USER" == "aa" ]; then
        APACHE_RUN_USER=www-data
    fi
}

function validateDocRootIsEmpty
{
#    if [ "$(ls /tmp/aaa)" ]; then
    if [ "$(ls /var/www)" ]; then
        echo "Error : Docroot is not empty"
        exit 1
    else
        return 0
    fi
}

function installViaComposer
{
    validateDocRootIsEmpty
    cd /tmp
    local tmpDir
    local repositoryParameter

    mkdir -p $HOME/.composer
    ln -s -f /volumes/composercache $HOME/.composer/cache

    tmpDir=`mktemp -d`
    #tmpDir="tmp.747Uy8crCV"

    cd $tmpDir

    mkdir -p $HOME/.composer
    cp /auth.json $HOME/.composer

    if [ "aa$EZ_COMPOSERREPOSITORYURL" == "aa" ]; then
        repositoryParameter=""
    else
        repositoryParameter="--repository-url=$EZ_COMPOSERREPOSITORYURL "
    fi

    composer --no-interaction create-project --prefer-dist ${repositoryParameter}ezsystems/ezpublish-community ezp $EZ_COMPOSERVERSION;

    # Remove ezpublish/cache/prod, needed since we'll move ezpublish root
    rm -Rf ezp/ezpublish/cache/prod

    mv ezp/* /var/www

    cd ..
    rm -Rf $tmpDir

    rm $HOME/.composer/auth.json

}

function installTarball
{
    validateDocRootIsEmpty
    cd /tmp
    local tmpDir
    local repositoryParameter

    tmpDir=`mktemp -d`
    #tmpDir="tmp.747Uy8crCV"

    cd $tmpDir

    tar -xzf /tmp/ezpublish.tar.gz

    mv ezpublish5/* /var/www

    cd /var/www
#    php ezpublish/console assets:install --relative --symlink web
#    php ezpublish/console ezpublish:legacy:assets_install --relative --symlink web
#    php ezpublish/console assetic:dump --env=prod web
}

function processCommandLineOptions
{
    if [ $EZ_INSTALLTYPE == "composer" ]; then
        installViaComposer
    fi

    if [ $EZ_INSTALLTYPE == "tarball" ]; then
        installTarball
    fi

    if [ $EZ_INSTALLTYPE == "donothing" ]; then
        exit 0
    fi
}

# db container might not be ready, so let's wait for it in such case
function createMysqlDatabase
{
    local DBUP
    local TRY
    DBUP=false
    TRY=1
    while [ $DBUP == "false" ]; do
        echo Contacting mysql, attempt :$TRY
        mysql -uadmin --password=$DB_ENV_MYSQL_PASS --protocol=tcp --host=db -e "CREATE DATABASE IF NOT EXISTS ezp CHARACTER SET=utf8" && DBUP="true"
        let TRY=$TRY+1
        if [ $TRY -eq $MAXTRY ]; then
            echo Max limit reached. Not able to connect to mysql
            echo Command:
            echo mysql -uadmin --password=$DB_ENV_MYSQL_PASS --protocol=tcp --host=db -e "CREATE DATABASE IF NOT EXISTS ezp CHARACTER SET=utf8"
            echo /etc/hosts file :
            cat /etc/hosts
            exit 1;
        fi
        sleep 2;
    done
}

parseCommandlineOptions $1 $2 $3 $4 $5

processCommandLineOptions

# Make sure we are within root www dir
cd /var/www/


# Prepare for setup wizard if requested
if [ "$EZ_KICKSTART" = "true" ]; then
  /generate_kickstart_file.sh
fi

# Dowload packages if requested
if [ "$EZ_PACKAGEURL" != "" ]; then
  /install_packages.sh
fi


echo "Setting permissions on eZ Publish folder as they might be broken if rsync is used"
sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx \
     ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var} web
sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx \
     ezpublish/{cache,logs,config,sessions} ezpublish_legacy/{design,extension,settings,var} web


echo "Re-generate symlink assets in case rsync was used so asstets added during setup wizards are reachable"
if [ aa$EZ_ENVIRONMENT != "prod" ]; then
    php ezpublish/console assetic:dump --env $EZ_ENVIRONMENT
fi

php ezpublish/console assets:install --symlink --relative --env $EZ_ENVIRONMENT
php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env $EZ_ENVIRONMENT


# Create ezp database if we intend to run setup wizard (need to be run last to make sure db is up)
if [ "$EZ_KICKSTART" = "true" ]; then
  echo "Creating database if it does not exists"
  createMysqlDatabase
fi

