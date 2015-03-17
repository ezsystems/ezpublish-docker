FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

ENV NGINXPORT 80
ENV BASEDIR /var/www
# If you change FASTCGI_READ_TIMEOUT, also change max_execution_time accordingly in php-fpm!
ENV FASTCGI_READ_TIMEOUT 190


RUN apt-get update -y && apt-get install -y \
    supervisor \
    nginx

ADD etcd_0.4.6_amd64.deb /etcd_0.4.6_amd64.deb
RUN dpkg -i /etcd_0.4.6_amd64.deb
ADD etcd_functions /etcd_functions

RUN rm /etc/nginx/sites-enabled/default

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# configure supervisord
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
ADD supervisord-base.conf-part /supervisord-base.conf-part
ADD supervisord-etcd.conf-part /supervisord-etcd.conf-part

ADD watch_phpfpm_ip.sh /watch_phpfpm_ip.sh
ADD run.sh /run.sh

CMD ["/run.sh"]

EXPOSE 80
