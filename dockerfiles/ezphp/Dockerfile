FROM debian:jessie

# Container containing php-fpm and php-cli to run and interact with eZ Platform
#
# It has two modes of operation:
# - (default run.sh cmd) Reconfigure eZ Platform/Publish based on provided env variables and start php-fpm
# - (bash|php|composer) Allows to execute composer, php or bash against the install

# Set defaults for variables used by run.sh
# If you change MAX_EXECUTION TIME, also change fastcgi_read_timeout accordingly in nginx!
ENV DEBIAN_FRONTEND=noninteractive \
    TIMEZONE=Europe/Warsaw \
    MEMORY_LIMIT=256M \
    MAX_EXECUTION_TIME=90 \
    PORT=9000 \
    COMPOSER_HOME=/var/.composer

## Get packages
RUN apt-get update -q -y \
 && apt-get install -q -y --force-yes --no-install-recommends \
    php5-cli \
    php5-readline \
    php5-fpm \
    php5-mysqlnd \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    php5-twig \
    mysql-client \
    imagemagick \
    curl \
    wget \
    ca-certificates \
    less \
    vim \
    git \
    acl \
    tree \
    patch \
    && rm -rf /var/lib/apt/lists/*

# Create Composer directory (cache and auth files)
RUN mkdir -p $COMPOSER_HOME

# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

# Set memory limit
RUN sed -i "s@^memory_limit =.*@memory_limit = $MEMORY_LIMIT@" /etc/php5/fpm/php.ini

# Increase realpath_cache_size
RUN sed -i "s@^;realpath_cache_size =.*@realpath_cache_size = 128k@" /etc/php5/fpm/php.ini

# Set Max execution time
RUN sed -i "s@^max_execution_time = .*@max_execution_time = $MAX_EXECUTION_TIME@" /etc/php5/fpm/php.ini

# Disable daemonizeing php-fpm
RUN sed -i "s@^;daemonize = yes*@daemonize = no@" /etc/php5/fpm/php-fpm.conf

# Set listen socket for php-fpm
RUN sed -i "s@^listen = /var/run/php5-fpm.sock@listen = $PORT@" /etc/php5/fpm/pool.d/www.conf

# Get Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

# As application is put in as volume we do all needed operation on run
ADD run.sh /run.sh
ADD generate_kickstart_file.sh /generate_kickstart_file.sh
ADD generate_parameters_file.sh /generate_parameters_file.sh
ADD prepare_distribution_volume.sh /prepare_distribution_volume.sh
ADD config/opcache.ini /etc/php5/mods-available/opcache.ini

RUN chmod 755 /*.sh

WORKDIR /var/www

CMD /run.sh

EXPOSE 9000
