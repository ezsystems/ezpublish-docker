FROM debian:jessie

RUN apt-get update -q -y && apt-get install -q -y --force-yes --no-install-recommends \
    php5-cli \
    php5-readline \
    php5-mysqlnd \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    php5-twig \
    imagemagick \
    curl \
    ca-certificates \
    wget \
    vim \
    git \
    acl \
    tree \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

WORKDIR /var/www

CMD /bin/bash
