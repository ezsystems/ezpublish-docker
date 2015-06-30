FROM debian:jessie

# If you change MAX_EXECUTION TIME, also change fastcgi_read_timeout accordingly in nginx!
ENV DEBIAN_FRONTEND=noninteractive \
    TIMEZONE=Europe/Warsaw \
    MEMORY_LIMIT=256M \
    MAX_EXECUTION_TIME=180 \
    PORT=9000

RUN apt-get update -q -y && apt-get install -q -y --force-yes --no-install-recommends \
    php5-fpm \
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
    && rm -rf /var/lib/apt/lists/*

# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

# Set memory limit
RUN sed -i "s@^memory_limit =.*@memory_limit = $MEMORY_LIMIT@" /etc/php5/fpm/php.ini

# Increase realpath_cache_size
RUN sed -i "s@^;realpath_cache_size =.*@realpath_cache_size = 128k@" /etc/php5/fpm/php.ini

# Set Max execution time
RUN sed -i "s@^max_execution_time = .*@max_execution_time = $MAX_EXECUTION_TIME@" /etc/php5/fpm/php.ini

# Set Debug level
#RUN sed -i "s@^;log_level = notice@log_level = debug@" /etc/php5/fpm/php-fpm.conf

# Disable daemonizeing php-fpm
RUN sed -i "s@^;daemonize = yes*@daemonize = no@" /etc/php5/fpm/php-fpm.conf

# Set listen socket for php-fpm
RUN sed -i "s@^listen = /var/run/php5-fpm.sock@listen = $PORT@" /etc/php5/fpm/pool.d/www.conf

# Add config for opcache to optimize it
ADD config/opcache.ini /etc/php5/mods-available/opcache.ini

WORKDIR /var/www

CMD ["/usr/sbin/php5-fpm"]

EXPOSE 9000
