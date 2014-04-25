FROM ezsystems/apache-php:dev

# Install supervisor so we can run ssh for debug / dev needs
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor openssh-server
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd

# As application is put in as volume we do all needed operation on run
ADD run.sh /run.sh
ADD generate_kickstart_file.sh /generate_kickstart_file.sh
ADD install_packages.sh /install_packages.sh
RUN chmod 755 /*.sh

ADD supervisord-httpssh.conf /etc/supervisor/conf.d/supervisord-httpssh.conf

CMD /run.sh

EXPOSE 22 80
