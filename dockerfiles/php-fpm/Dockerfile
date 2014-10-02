FROM ezsystems/ubuntu:apt-get

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE Europe/Warsaw
ENV MEMORY_LIMIT 256M
ENV MAX_EXECUTION_TIME 180
ENV PORT 9000

RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get install -y \
    php5-fpm \
    php5-mysql \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    curl \
    mysql-client

# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

# Set memory limit
RUN sed -i "s@^memory_limit =.*@memory_limit = $MEMORY_LIMIT@" /etc/php5/fpm/php.ini

# Set Max execution time
RUN sed -i "s@^max_execution_time = .*@max_execution_time = $MAX_EXECUTION_TIME@" /etc/php5/fpm/php.ini

# Disable daemonizeing php-fpm
RUN sed -i "s@^;daemonize = yes*@daemonize = no@" /etc/php5/fpm/php-fpm.conf

# Set listen socket for php-fpm
RUN sed -i "s@^listen = /var/run/php5-fpm.sock@listen = $PORT@" /etc/php5/fpm/pool.d/www.conf

CMD ["/usr/sbin/php5-fpm"]

EXPOSE 9000
