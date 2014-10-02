FROM ezsystems/ubuntu:apt-get

ENV DEBIAN_FRONTEND noninteractive

ENV PORT 80
ENV BASEDIR /var/www

RUN apt-get install -y \
    nginx


RUN rm /etc/nginx/sites-enabled/default

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ADD run.sh /run.sh

CMD ["/run.sh"]

EXPOSE 80
