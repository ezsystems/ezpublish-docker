#!/bin/bash

export FIG_PROJECT_NAME=ezpublishdocker

# Load default settings
source files/fig.config-EXAMPLE

# Load custom settings
source files/fig.config

if [ $DISTRIBUTION == "debian" ]; then
    BASE_DOCKERFILES="dockerfiles/debian"
else
    BASE_DOCKERFILES="dockerfiles/ubuntu"
fi

if [ -f files/auth.json ]; then
    cp files/auth.json dockerfiles/ezpublish/install
else
    touch dockerfiles/ezpublish/install/auth.json
fi

if [ $DISTRIBUTION == "ubuntu" ]; then
    cp files/etcd_functions $BASE_DOCKERFILES/etcd
    cp files/etcd_functions $BASE_DOCKERFILES/mysql
    cp files/etcd_functions $BASE_DOCKERFILES/php-fpm
    cp files/etcd_functions $BASE_DOCKERFILES/nginx
    cp files/etcd_functions $BASE_DOCKERFILES/varnish
fi

# If {FIX_EXECUTION_PATH} is not set and fig is not in path, we'll test if it is located in /opt/bin. Needed for systemd service
if [ aa$FIX_EXECUTION_PATH == "aa" ]; then
    if [ ! `which ${FIX_EXECUTION_PATH}fig > /dev/null` ]; then
        if [ -x "/opt/bin/fig" ]; then
            FIX_EXECUTION_PATH="/opt/bin/"
        fi
    fi
fi

cp resources/setupwizard_ezstep_welcome.patch dockerfiles/ezpublish/install

# Copy kickstart template to build dir
if [ "aa$EZ_KICKSTART_FROM_TEMPLATE" != "aa" ]; then
    cp files/$EZ_KICKSTART_FROM_TEMPLATE dockerfiles/ezpublish/install/kickstart_template.ini
else
    echo "" > dockerfiles/ezpublish/install/kickstart_template.ini
fi

cp resources/ezpublish.yml_varnishpurge.diff $BASE_DOCKERFILES/ezpublish/varnish_prepare/

# Make a argumentlist where any "-d" is removed
for i in "$@"; do
    if [ $i != "-d" ]; then
        arglistnodetach="$arglistnodetach $i"
    fi
done

# This is a workaround for https://github.com/docker/fig/issues/540
if [ $DISTRIBUTION == "ubuntu" ]; then
    # We need to build etcd next so that the .deb package can be placed inside other images
    if [ ! -f volumes/etcd/etcd_0.4.6_amd64.deb ]; then
        ${FIX_EXECUTION_PATH}fig -f fig_etcd.yml $arglistnodetach
    fi

    # Copy the etcd .deb to the dockerfile directory for images that need it
    if [ ! -f $BASE_DOCKERFILES/mysql/etcd_0.4.6_amd64.deb ]; then
        cp volumes/etcd/etcd_0.4.6_amd64.deb $BASE_DOCKERFILES/mysql
    fi
    if [ ! -f $BASE_DOCKERFILES/php-fpm/etcd_0.4.6_amd64.deb ]; then
        cp volumes/etcd/etcd_0.4.6_amd64.deb $BASE_DOCKERFILES/php-fpm
    fi
    if [ ! -f $BASE_DOCKERFILES/nginx/etcd_0.4.6_amd64.deb ]; then
        cp volumes/etcd/etcd_0.4.6_amd64.deb $BASE_DOCKERFILES/nginx
    fi

    ${FIX_EXECUTION_PATH}fig -f fig_ubuntu.yml "$@"
else
    ${FIX_EXECUTION_PATH}fig -f fig_debian.yml "$@"
fi


