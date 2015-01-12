FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE Europe/Warsaw
ENV MEMORY_LIMIT 256M
# If you change MAX_EXECUTION TIME, also change fastcgi_read_timeout accordingly in nginx!
ENV MAX_EXECUTION_TIME 180
ENV PORT 9000

RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get update -y && apt-get install -y \
    php5-fpm \
    php5-mysql \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    curl \
    supervisor \
    mysql-client

ADD etcd_0.4.6_amd64.deb /etcd_0.4.6_amd64.deb
RUN dpkg -i /etcd_0.4.6_amd64.deb
ADD etcd_functions /etcd_functions

# Set timezone
RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

# Set memory limit
RUN sed -i "s@^memory_limit =.*@memory_limit = $MEMORY_LIMIT@" /etc/php5/fpm/php.ini

# Set Max execution time
RUN sed -i "s@^max_execution_time = .*@max_execution_time = $MAX_EXECUTION_TIME@" /etc/php5/fpm/php.ini

# Set Debug level
#RUN sed -i "s@^;log_level = notice@log_level = debug@" /etc/php5/fpm/php-fpm.conf

# Disable daemonizeing php-fpm
RUN sed -i "s@^;daemonize = yes*@daemonize = no@" /etc/php5/fpm/php-fpm.conf

# Set listen socket for php-fpm
RUN sed -i "s@^listen = /var/run/php5-fpm.sock@listen = $PORT@" /etc/php5/fpm/pool.d/www.conf

# configure supervisord
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
ADD supervisord-base.conf-part /supervisord-base.conf-part
ADD supervisord-etcd.conf-part /supervisord-etcd.conf-part

ADD watch_db_ip.sh /watch_db_ip.sh
ADD run.sh /run.sh

CMD ["/run.sh"]

EXPOSE 9000
