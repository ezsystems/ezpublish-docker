FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive

ENV PORT 80
ENV BASEDIR /var/www
# If you change FASTCGI_READ_TIMEOUT, also change max_execution_time accordingly in php-fpm!
ENV FASTCGI_READ_TIMEOUT 190


RUN apt-get update && \
    apt-get install -y \
    nginx

RUN rm /etc/nginx/sites-enabled/default

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ADD run.sh /run.sh

ADD ezpublish_config_fallback /ezpublish_config_fallback

CMD ["/run.sh"]

EXPOSE 80
