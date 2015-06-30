FROM debian:wheezy

RUN apt-get update -y && apt-get install -y --force-yes \
    php5-cli \
    php5-mysqlnd \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    curl \
    wget \
    vim \
    git \
    acl \
    tree

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

WORKDIR /var/www

CMD /bin/bash
