FROM ezsystems/ubuntu:apt-get

## This image is for decreasing the amount of coffee breaks during development.
## This base image prevents other images from also having to do apt-get install of php packages

RUN apt-get install -y --force-yes \
    php5 \
    php5-mysql \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    mysql-client
    curl \
    wget \
    vim \
    git \
    acl \
    tree

CMD /bin/true
