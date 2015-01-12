#!/bin/bash

export FIG_PROJECT_NAME=ezpublishdocker

source files/fig.config

if [ $DISTRIBUTION == "debian" ]; then
    BASE_DOCKERFILES="dockerfiles/debian"
else
    BASE_DOCKERFILES="dockerfiles"
fi

if [ -f files/auth.json ]; then
    cp files/auth.json $BASE_DOCKERFILES/ezpublish/prepare
else
    touch $BASE_DOCKERFILES/ezpublish/prepare/auth.json
fi

if [ $DISTRIBUTION == "ubuntu" ]; then
    cp files/etcd_functions $BASE_DOCKERFILES/etcd
    cp files/etcd_functions $BASE_DOCKERFILES/mysql
    cp files/etcd_functions $BASE_DOCKERFILES/php-fpm
    cp files/etcd_functions $BASE_DOCKERFILES/nginx
fi

# If {FIX_EXECUTION_PATH} is not set and fig is not in path, we'll test if it is located in /opt/bin. Needed for systemd service
if [ aa$FIX_EXECUTION_PATH == "aa" ]; then
    if [ ! `which ${FIX_EXECUTION_PATH}fig > /dev/null` ]; then
        if [ -x "/opt/bin/fig" ]; then
            FIX_EXECUTION_PATH="/opt/bin/"
        fi
    fi
fi

cp resources/setupwizard_ezstep_welcome.patch dockerfiles/ezpublish/prepare
cp resources/setupwizard_ezstep_welcome.patch dockerfiles/debian/ezpublish/prepare

# Copy kickstart template to build dir
if [ "aa$EZ_KICKSTART_FROM_TEMPLATE" != "aa" ]; then
    cp files/$EZ_KICKSTART_FROM_TEMPLATE $BASE_DOCKERFILES/ezpublish/prepare/kickstart_template.ini
else
    echo "" > $BASE_DOCKERFILES/ezpublish/prepare/kickstart_template.ini
fi

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
    if [ ! -f dockerfiles/mysql/etcd_0.4.6_amd64.deb ]; then
        cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/mysql
        cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/php-fpm
        cp volumes/etcd/etcd_0.4.6_amd64.deb dockerfiles/nginx
    fi

    ${FIX_EXECUTION_PATH}fig "$@"
else
    ${FIX_EXECUTION_PATH}fig -f fig_debian.yml "$@"
fi


echo "Waiting for prepare container to complete"
continue=1; while [ $continue -eq 1 ]; do docker ps -a|grep "${FIG_PROJECT_NAME}_prepare:latest"|grep Exited > /dev/null; continue=$?; echo -n "."; sleep 3; done;

echo "Last output from prepare container:"
echo "###################################"
docker logs -t ${FIG_PROJECT_NAME}_prepare_1|tail -n 15
