FROM sample/apache-php:prod

RUN apt-get update -y
RUN apt-get install -y vim git tree

# Install & Configure xdebug
RUN apt-get install -y php5-xdebug
RUN php5enmod xdebug

ADD xdebug.ini /xdebug.ini
RUN sed -i "s@EXTENSION_DIR@`php -i | grep extension_dir | awk '{print $(NF)}'`@" /xdebug.ini
RUN mv /xdebug.ini /etc/php5/mods-available/xdebug.ini

# Install & Configure  webgrind
RUN mkdir -p /srv/webgrind/
RUN git clone git://github.com/jokkedk/webgrind.git /srv/webgrind

ADD webgrind.conf /etc/apache2/conf-available/webgrind.conf
RUN a2enconf webgrind.conf
RUN sed -i "s@Europe/Copenhagen@$TIMEZONE@" /srv/webgrind/config.php
RUN sed -i "s@/usr/local/bin/dot@/usr/bin/dot@" /srv/webgrind/config.php

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80