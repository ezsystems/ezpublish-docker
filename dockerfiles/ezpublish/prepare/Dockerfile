FROM ezpublishdocker_phpclibase


# As application is put in as volume we do all needed operation on run
ADD run.sh /run.sh
ADD generate_kickstart_file.sh /generate_kickstart_file.sh
ADD install_packages.sh /install_packages.sh
ADD auth.json /auth.json
ADD setupwizard_ezstep_welcome.patch /setupwizard_ezstep_welcome.patch
ADD kickstart_template.ini /kickstart_template.ini

RUN chmod 755 /*.sh

CMD /run.sh

