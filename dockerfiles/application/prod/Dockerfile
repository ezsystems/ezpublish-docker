FROM ezpublish/apache-php:prod

## broken, this won't work, should use volumes instead like :dev
ADD ../../../ezpublish /srv/ezpublish

RUN rm -rf /srv/ezpublish/ezpublish/cache/* /srv/ezpublish/ezpublish/logs/*
RUN cd /srv/ezpublish && composer install -n --no-dev
RUN rm -rf /var/www
RUN ln -s /srv/ezpublish/web /var/www
RUN chown -R www-data:www-data /srv/ezpublish


CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80