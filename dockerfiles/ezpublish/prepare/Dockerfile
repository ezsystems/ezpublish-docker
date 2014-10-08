FROM ezsystems/php-cli:base


# As application is put in as volume we do all needed operation on run
ADD run.sh /run.sh
ADD generate_kickstart_file.sh /generate_kickstart_file.sh
ADD install_packages.sh /install_packages.sh
RUN chmod 755 /*.sh

CMD /run.sh

