FROM ezpublishdocker_ubuntu

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
    mysql-client \
    curl \
    wget \
    vim \
    git \
    acl \
    tree

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

CMD /bin/true
