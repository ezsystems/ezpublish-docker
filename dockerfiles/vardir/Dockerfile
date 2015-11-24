FROM debian:jessie

add vardir.tar.gz /var/www/web
# Make sure /var/www/ is also owned by ez user
RUN chown 10000:10000 /var/www

VOLUME [ "/var/www/web/var" ]

CMD ["/bin/true"]

