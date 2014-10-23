# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

vagrantConfig = YAML::load_file( "files/vagrant.yml" )

Vagrant.configure("2") do |config|
  config.vm.box = "coreos-%s" % vagrantConfig['virtualmachine']['coreos_channel']
  config.vm.box_version = ">= 410.2.0"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % vagrantConfig['virtualmachine']['coreos_channel']

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + vagrantConfig['virtualmachine']['timezone'] + "\" | sudo tee /etc/timezone"

  # Pull in the external docker images we need
  if vagrantConfig['debug']['disable_docker_pull'] == false
    config.vm.provision "docker",
      images: ["ubuntu:trusty", "tutum/mysql"]
  end


  FileUtils.cp( "files/auth.json", "dockerfiles/ezpublish/prepare" )

  if vagrantConfig['ezpublish']['install_type'] == 'tarball'
    tarballVolArg = "-v /vagrant/" + vagrantConfig['ezpublish']['tarball_filename'] + ":/tmp/ezpublish.tar.gz:ro"
  else
    tarballVolArg = ""
  end

  config.vm.provision "docker" do |d|
    d.build_image "/vagrant/dockerfiles/ubuntu",          args: "-t 'ezpublishdocker_ubuntu'"
    d.build_image "/vagrant/dockerfiles/nginx",          args: "-t 'ezpublishdocker_nginx'"
    d.build_image "/vagrant/dockerfiles/php-fpm",          args: "-t 'ezpublishdocker_phpfpm'"
    d.build_image "/vagrant/dockerfiles/php-cli/base",         args: "-t 'ezpublishdocker_phpclibase'"
    d.build_image "/vagrant/dockerfiles/php-cli",         args: "-t 'ezpublishdocker_phpcli'"
    d.build_image "/vagrant/dockerfiles/ezpublish/prepare",   args: "-t 'ezpublishdocker_prepare'"
  end

  # Startup the docker images we need
  config.vm.provision "docker" do |d|
    d.run "db-vol",
      image: "ezpublishdocker_ubuntu",
      args: "-v /vagrant/volumes/mysql:/var/lib/mysql:rw",
      daemonize: false
    d.run "ezpublish-vol",
      image: "ezpublishdocker_ubuntu",
      args: "-v /vagrant/volumes/ezpublish:/var/www:rw",
      daemonize: false
    d.run "composercache-vol",
      image: "ezpublishdocker_ubuntu",
      args: "-v /vagrant/volumes/composercache:/.composer/cache:rw",
      daemonize: false
    d.run "db-1",
      image: "tutum/mysql",
      args: "--volumes-from db-vol -e MYSQL_PASS=\""+ vagrantConfig['dbserver']['password'] + "\""
    d.run "prepare",
      image: "ezpublishdocker_prepare",
      args: "--rm --link db-1:db --dns 8.8.8.8 --dns 8.8.4.4 -m 1024m --volumes-from ezpublish-vol --volumes-from composercache-vol \
        " + tarballVolArg + "\
        -e EZ_KICKSTART=\""+ vagrantConfig['ezpublish']['kickstart'] +"\" \
        -e EZ_PACKAGEURL=\""+ vagrantConfig['ezpublish']['packageurl'] +"\" \
        -e EZ_INSTALLTYPE=\""+ vagrantConfig['ezpublish']['install_type'] +"\"  \
        -e EZ_COMPOSERVERSION=\""+ vagrantConfig['ezpublish']['composer_version'] +"\"  \
        -e EZ_COMPOSERREPOSITORYURL=\""+ vagrantConfig['ezpublish']['composer_repository_url'] +"\"",
      daemonize: false
    d.run "php-fpm",
      image: "ezpublishdocker_phpfpm",
      args: "--link db-1:db --dns 8.8.8.8 --dns 8.8.4.4 --volumes-from ezpublish-vol"
    d.run "web-nginx",
      image: "ezpublishdocker_nginx",
      args: "--link php-fpm:php_fpm --dns 8.8.8.8 --dns 8.8.4.4 -p 80:80 --volumes-from ezpublish-vol"
  end

  if vagrantConfig['debug']['copy_authorized_keys2'] == true
    ssh_authorized_keys_file = File.read( "files/authorized_keys2" )
    config.vm.provision :shell, :inline => "
      echo 'Copying SSH authorized_keys2 to VM for provisioning...' ; \
      mkdir -m 700 -p /root/.ssh ; \
      echo '#{ssh_authorized_keys_file }' > /root/.ssh/authorized_keys2 && chmod 600 /root/.ssh/authorized_keys2
    "
    config.vm.provision :shell, :inline => "
      echo '#{ssh_authorized_keys_file }' > /home/core/.ssh/authorized_keys2 && chmod 600 /home/core/.ssh/authorized_keys2 && chown core:core /home/core/.ssh/authorized_keys2
    "
  end

  if vagrantConfig['debug']['disable_rsync'] == false
    config.vm.synced_folder ".", "/vagrant", type: "rsync",
      rsync__exclude: [ ".git/", "volumes/ezpublish/.git/"],
      rsync__auto: true
  end

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: vagrantConfig['virtualmachine']['network']['private_network_ip']
  config.vm.network "public_network"

  config.vm.hostname = vagrantConfig['virtualmachine']['hostname']

  config.vm.provider :virtualbox do |vb|
     vb.check_guest_additions = false
     vb.functional_vboxsf = false
     vb.gui = false
     vb.memory = vagrantConfig['virtualmachine']['ram']
     vb.cpus = vagrantConfig['virtualmachine']['cpus']
     vb.customize ["modifyvm", :id, "--ostype", "Linux26_64"]
  end

  # Vagrant plugin conflict with coreos
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

end
