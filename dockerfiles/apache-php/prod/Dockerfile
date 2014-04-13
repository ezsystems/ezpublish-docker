FROM ezsystems/apache

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE Europe/Warsaw

RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

# update and install
RUN apt-get install -y --force-yes \
    php5 \
    libapache2-mod-php5 \
    php5-mysql \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    curl \
    mysql-client

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80