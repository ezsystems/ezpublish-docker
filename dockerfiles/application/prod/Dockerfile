FROM sample/apache-php:prod

ADD ../../../application /srv/application

RUN rm -rf /srv/application/app/cache/* /srv/application/app/logs/*
RUN cd /srv/application && composer install -n --no-dev
RUN rm -rf /var/www
RUN ln -s /srv/application/web /var/www
RUN chown -R www-data:www-data /srv/application

RUN rm /srv/application/web/app_dev.php