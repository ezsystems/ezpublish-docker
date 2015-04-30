FROM debian:jessie

RUN apt-get update -y && apt-get install -y --force-yes \
    php5-cli \
    php5-mysql \
    php5-json \
    php5-xsl \
    php5-intl \
    php5-mcrypt \
    php5-gd \
    php5-curl \
    mysql-client \
    curl \
    wget \
    vim \
    git \
    acl \
    tree

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

# As application is put in as volume we do all needed operation on run
ADD run.sh /run.sh
ADD generate_kickstart_file.sh /generate_kickstart_file.sh
ADD install_packages.sh /install_packages.sh
ADD auth.json /auth.json
ADD setupwizard_ezstep_welcome.patch /setupwizard_ezstep_welcome.patch
ADD kickstart_template.ini /kickstart_template.ini
ADD generate_parameters_file.sh /generate_parameters_file.sh

RUN chmod 755 /*.sh

CMD /run.sh

