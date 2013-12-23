FROM sample/apache

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE Europe/Warsaw

RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

# Add PHP 5.5 repository
RUN apt-get update -y
RUN apt-get install software-properties-common -y
RUN apt-add-repository ppa:ondrej/php5 -y
RUN apt-get update -y

# install PHP
RUN apt-get install -y --force-yes php5 libapache2-mod-php5 php5-mysql php5-json php5-xsl php5-intl php5-mcrypt

# install utils
RUN apt-get install -y curl

# apt clean
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80