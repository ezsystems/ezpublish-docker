FROM busybox

add ezpublish.tar.gz /var/www
# Make sure /var/www is also owned by ez user
RUN chown 10000:10000 /var/www

VOLUME [ "/var/www" ]

CMD ["/bin/true"]

