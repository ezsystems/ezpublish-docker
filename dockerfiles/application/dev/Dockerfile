FROM sample/apache-php:dev

RUN rm -rf /var/www
RUN ln -s /srv/application/web /var/www

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80