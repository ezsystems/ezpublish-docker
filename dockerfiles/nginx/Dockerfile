FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

#ENV APACHE_RUN_USER     www-data
#ENV APACHE_RUN_GROUP    www-data
#ENV APACHE_PID_FILE     /var/run/apache2.pid
#ENV APACHE_RUN_DIR      /var/run/apache2
#ENV APACHE_LOCK_DIR     /var/lock/apache2
#ENV APACHE_LOG_DIR      /var/log/apache2

ENV PORT 80
ENV BASEDIR /var/www

RUN apt-get update -y && apt-get install -y \
    nginx


RUN rm /etc/nginx/sites-enabled/default

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ADD run.sh /run.sh

#CMD ["/usr/sbin/nginx"]
#CMD ["bash"]
#CMD ["bash", "-c", "/a.sh"]
CMD ["/run.sh"]

EXPOSE 80