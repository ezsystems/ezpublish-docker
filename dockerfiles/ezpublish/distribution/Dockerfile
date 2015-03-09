FROM scratch

add true /bin/true
add true /bin/echo
add libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
add ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2


add ezpublish.tar.gz /var/www

VOLUME ["/var/www"]


CMD ["/bin/true"]

