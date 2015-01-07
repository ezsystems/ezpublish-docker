#!/bin/bash

if [ -f files/auth.json ]; then
    cp files/auth.json dockerfiles/ezpublish/prepare
else
    touch dockerfiles/ezpublish/prepare/auth.json
fi
cp files/etcd_functions dockerfiles/etcd
cp files/etcd_functions dockerfiles/mysql
cp files/etcd_functions dockerfiles/php-fpm
cp files/etcd_functions dockerfiles/nginx

export FIG_PROJECT_NAME=ezpublishdocker

source files/fig.config

# If {FIX_EXECUTION_PATH} is not set and fig is not in path, we'll test if it is located in /opt/bin. Needed for systemd service
if [ aa$FIX_EXECUTION_PATH == "aa" ]; then
    if [ ! `which ${FIX_EXECUTION_PATH}fig > /dev/null` ]; then
        if [ -x "/opt/bin/fig" ]; then
            FIX_EXECUTION_PATH="/opt/bin/"
        fi
    fi
fi

# Copy kickstart template to build dir
if [ "aa$EZ_KICKSTART_FROM_TEMPLATE" != "aa" ]; then
    cp files/$EZ_KICKSTART_FROM_TEMPLATE dockerfiles/ezpublish/prepare/kickstart_template.ini
else
    echo "" > dockerfiles/ezpublish/prepare/kickstart_template.ini
fi

# Make a argumentlist where any "-d" is removed
for i in "$@"; do
    if [ $i != "-d" ]; then
        arglistnodetach="$arglistnodetach $i"
    fi
done

# This is a workaround for https://github.com/docker/fig/issues/540
${FIX_EXECUTION_PATH}fig -f fig_initial.yml "$@"

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

echo "Waiting for prepare container to complete"
continue=1; while [ $continue -eq 1 ]; do docker ps -a|grep "${FIG_PROJECT_NAME}_prepare:latest"|grep Exited > /dev/null; continue=$?; echo -n "."; sleep 3; done;

echo "Last output from prepare container:"
echo "###################################"
docker logs -t ezpublishdocker_prepare_1|tail -n 15
