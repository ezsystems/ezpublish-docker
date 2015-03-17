FROM scratch

add true /bin/true
add echo /bin/echo
add dash /bin/sh
add sleep /bin/sleep
add libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
add ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2


copy ezp.sql /dbdump/ezp.sql

VOLUME ["/dbdump"]


CMD ["/bin/true"]
