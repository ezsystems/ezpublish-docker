#!/bin/bash


set -e

export FIG_PROJECT_NAME=ezpublishdocker
source files/fig_ezpcontainer.config-EXAMPLE
source files/fig_ezpcontainer.config
MAINFIG="fig_${DISTRIBUTION}.yml"
DATE=`date +%Y%m%d`


function tag_service_containers
{
    docker tag -f ${FIG_PROJECT_NAME}_nginx:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/nginx:${DOCKER_BUILDVER}
    docker tag -f ${FIG_PROJECT_NAME}_phpfpm:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/phpfpm:${DOCKER_BUILDVER}
    docker tag -f ${FIG_PROJECT_NAME}_db1:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/db1:${DOCKER_BUILDVER}
    docker tag -f ${FIG_PROJECT_NAME}_phpcli:latest ${DOCKER_REPOSITORY}/${DOCKER_USER}/phpcli:${DOCKER_BUILDVER}

}

function push_service_containers
{
    echo docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/nginx:${DOCKER_BUILDVER}
    echo docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/phpfpm:${DOCKER_BUILDVER}
    echo docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/db1:${DOCKER_BUILDVER}
    echo docker push ${DOCKER_REPOSITORY}/${DOCKER_USER}/phpcli:${DOCKER_BUILDVER}
}

echo tag_service_containers
#tag_service_containers

echo push_service_containers
push_service_containers
