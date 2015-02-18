#!/bin/bash

# Script accepts the following environment variable:
# - EZ_KICKSTART ( "true" or "false" )
# - EZ_KICKSTART_FROM_TEMPLATE ( template file )
#   Note that the value of this setting passed on to this script is the filename outside the container. Inside the container, the actuall file will always be named /kickstart_template.ini
#   Therefore, the value of this setting will be rewritten internally in the script
# - EZ_PACKAGEURL ( url, pointing to url where packages are located )
# - EZ_INSTALLTYPE ( "composer" )
# - EZ_COMPOSERVERSION ( What version of eZ Publish to install using composer )
# - EZ_COMPOSERREPOSITORYURL ( Url to composer repository which should be used )
# - EZ_PATCH_SW ( "true" or "false" ) : Whatever to patch setup wizard or not, so that the welcome page also can be kickstarted
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
        EZ_KICKSTART_FROM_TEMPLATE=$2
    fi
    if [ "aa$3" != "aa" ]; then
        EZ_PACKAGEURL=$3
        export EZ_PACKAGEURL
    fi
    if [ "aa$4" != "aa" ]; then
        EZ_INSTALLTYPE=$4
    fi
    if [ "aa$5" != "aa" ]; then
        EZ_COMPOSERVERSION=$5
    fi
    if [ "aa$6" != "aa" ]; then
        EZ_COMPOSERREPOSITORYURL=$6
    fi
    if [ "aa$7" != "aa" ]; then
        EZ_PATCH_SW=$7
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


function patchSetupWizard
{
    local pwd
    pwd=`pwd`
    echo patch setup wizard ? : $EZ_PATCH_SW
    if [ "aa$EZ_PATCH_SW" == "aatrue" ]; then
        cd /var/www
        if [ -d ezpublish_legacy ]; then
            echo patching ....
            patch -p0 < /setupwizard_ezstep_welcome.patch
        else
            echo "Warning : Skipping patching setup wizard. ezpublish_legacy/ do not seem to be present"
        fi
        cd - > /dev/null

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

    patchSetupWizard

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

    patchSetupWizard

    cd /var/www
#    php ezpublish/console assets:install --relative --symlink web
#    php ezpublish/console ezpublish:legacy:assets_install --relative --symlink web
#    php ezpublish/console assetic:dump --env=prod web
}

function processCommandLineOptions
{
    # Fix value of KICKSTART_FROM_TEMPLATE
    if [ "aa$EZ_KICKSTART_FROM_TEMPLATE" != "aa" ]; then
        EZ_KICKSTART_FROM_TEMPLATE="/kickstart_template.ini"
    fi


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

parseCommandlineOptions $1 $2 $3 $4 $5

processCommandLineOptions

# Make sure we are within root www dir
cd /var/www/


# Prepare for setup wizard if requested
if [ "$EZ_KICKSTART" = "true" ]; then
  /generate_kickstart_file.sh $EZ_KICKSTART_FROM_TEMPLATE
fi

# Dowload packages if requested
if [ "$EZ_PACKAGEURL" != "" ]; then
  /install_packages.sh
fi

/generate_parameters_file.sh

echo "Setting permissions on eZ Publish folder as they might be broken if rsync is used"
sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web
sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish/{cache,logs,config,sessions} web

if [ -d ezpublish_legacy ]; then
    sudo setfacl -R -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
    sudo setfacl -dR -m u:$APACHE_RUN_USER:rwx -m u:`whoami`:rwx ezpublish_legacy/{design,extension,settings,var}
fi


echo "Re-generate symlink assets in case rsync was used so asstets added during setup wizards are reachable"
if [ aa$EZ_ENVIRONMENT != "prod" ]; then
    php ezpublish/console assetic:dump --env $EZ_ENVIRONMENT
fi

php ezpublish/console assets:install --symlink --relative --env $EZ_ENVIRONMENT
if [ -d ezpublish_legacy ]; then
    php ezpublish/console ezpublish:legacy:assets_install --symlink --relative --env $EZ_ENVIRONMENT
fi

