FROM tianon/ubuntu-core:14.04
#FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

RUN apt-get update -y && apt-get install -y \
    apache2

RUN a2enmod rewrite

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80