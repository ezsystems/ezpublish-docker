#!/bin/bash

echo "Installing (pre downloading) ezpublish packages"

PACKAGES="ezdemo_site.ezpkg ezwt_extension.ezpkg ezstarrating_extension.ezpkg ezgmaplocation_extension.ezpkg ezdemo_extension.ezpkg ezflow_extension.ezpkg ezdemo_classes.ezpkg ezdemo_democontent.ezpkg"
# Needs to be set by caller
#EZ_PACKAGEURL="http://packages.ez.no/ezpublish/5.3/5.3.0rc1/"

DOCROOT=""
PACKAGEREPOSITORY=""

function fetchPackages
{
    cd ezpublish_legacy
    if [ -d $PACKAGEREPOSITORY ]; then
        echo "Error: tmp/ already exists. Bailing out"
        exit
    fi

    mkdir $PACKAGEREPOSITORY
    cd $PACKAGEREPOSITORY

    for i in $PACKAGES; do
        echo -n "Downloading package $i ..."
        wget -q ${EZ_PACKAGEURL}${i}
        echo done!
    done
    cd ../..
}

function extractPackages
{
    local startDir
    local packageName
    startDir=`pwd`
    mkdir -p ${DOCROOT}/var/storage/packages/eZ-systems
    cd ${DOCROOT}/var/storage/packages/eZ-systems

    for i in $PACKAGES; do
        # cut of .ezpk from filename
        packageName=`echo $i|cut -f 1 -d "."`
        mkdir $packageName
        cd $packageName
        tar -xzf ${PACKAGEREPOSITORY}/$i
        cd - > /dev/null
    done
    cd $startDir
}

function preCheck
{
    if [ -d "ezpublish_legacy" ]; then
        echo "ezpublish_legacy/ directory located"
    else
        echo "Error: ezpublish_legacy/ doesn't exist. Bailing out"
        exit
    fi
    DOCROOT="`pwd`/ezpublish_legacy"
    PACKAGEREPOSITORY="`pwd`/ezpublish_legacy/tmp"
}

preCheck
fetchPackages
extractPackages
