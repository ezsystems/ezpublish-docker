# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

vagrantConfig = YAML::load_file( "files/vagrant.yml" )

Vagrant.configure("2") do |config|
  config.vm.box = "coreos-%s" % vagrantConfig['virtualmachine']['coreos_channel']
  config.vm.box_version = ">= 308.0.1"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % vagrantConfig['virtualmachine']['coreos_channel']

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + vagrantConfig['virtualmachine']['timezone'] + "\" | sudo tee /etc/timezone"

  # Pull in the external docker images we need
  if vagrantConfig['debug']['disable_docker_pull'] == false
    config.vm.provision "docker",
      images: ["ubuntu:trusty", "tutum/mysql"]
  end

  config.vm.provision "docker" do |d|
    d.build_image "/vagrant/dockerfiles/ubuntu",          args: "-t 'ezsystems/ubuntu:apt-get'"
    d.build_image "/vagrant/dockerfiles/nginx",          args: "-t 'ezsystems/nginx'"
    d.build_image "/vagrant/dockerfiles/php-fpm",          args: "-t 'ezsystems/php-fpm'"
    d.build_image "/vagrant/dockerfiles/apache",          args: "-t 'ezsystems/apache'"
    d.build_image "/vagrant/dockerfiles/apache-php/prod", args: "-t 'ezsystems/apache-php:prod'"
    d.build_image "/vagrant/dockerfiles/apache-php/dev",  args: "-t 'ezsystems/apache-php:dev'"
    d.build_image "/vagrant/dockerfiles/php-cli/base",         args: "-t 'ezsystems/php-cli:base'"
    d.build_image "/vagrant/dockerfiles/php-cli",         args: "-t 'ezsystems/php-cli'"
    #d.build_image "/vagrant/dockerfiles/ezpublish/prod", args: "-t 'ezsystems/ezpublish:prod'"
    d.build_image "/vagrant/dockerfiles/ezpublish/prepare",   args: "-t 'ezsystems/ezpublish:prepare'"
  end

  # Startup the docker images we need
  config.vm.provision "docker" do |d|
    # todo: we should persist the data to db dir in this folder (see https://github.com/tutumcloud/tutum-docker-mysql)
    d.run "db-1",
      image: "tutum/mysql",
      args: "-e MYSQL_PASS=\""+ vagrantConfig['dbserver']['password'] + "\""
    d.run "prepare",
      image: "ezsystems/ezpublish:prepare",
      args: "--rm --link db-1:db --dns 8.8.8.8 --dns 8.8.4.4 -p 80:80 -p 22 -v '/vagrant/ezpublish/:/var/www:rw' -e EZ_KICKSTART=\""+ vagrantConfig['ezpublish']['kickstart'] +"\" -e EZ_PACKAGEURL=\""+ vagrantConfig['ezpublish']['packageurl'] +"\"",
      daemonize: false
    d.run "php-fpm",
      image: "ezsystems/php-fpm",
      args: "--link db-1:db --dns 8.8.8.8 --dns 8.8.4.4 -p 22 -v '/vagrant/ezpublish/:/var/www:rw' -e EZ_KICKSTART=\""+ vagrantConfig['ezpublish']['kickstart'] +"\" -e EZ_PACKAGEURL=\""+ vagrantConfig['ezpublish']['packageurl'] +"\""
    d.run "web-nginx",
      image: "ezsystems/nginx",
      args: "--link php-fpm:php_fpm --dns 8.8.8.8 --dns 8.8.4.4 -p 81:80 -p 22 -v '/vagrant/ezpublish/:/var/www:rw' -e EZ_KICKSTART=\""+ vagrantConfig['ezpublish']['kickstart'] +"\" -e EZ_PACKAGEURL=\""+ vagrantConfig['ezpublish']['packageurl'] +"\""
  end

  ssh_authorized_keys_file = File.read( "files/authorized_keys2" )
  config.vm.provision :shell, :inline => "
    echo 'Copying SSH authorized_keys2 to VM for provisioning...' ; \
    mkdir -m 700 -p /root/.ssh ; \
    echo '#{ssh_authorized_keys_file }' > /root/.ssh/authorized_keys2 && chmod 600 /root/.ssh/authorized_keys2
  "
  config.vm.provision :shell, :inline => "
    echo '#{ssh_authorized_keys_file }' > /home/core/.ssh/authorized_keys2 && chmod 600 /home/core/.ssh/authorized_keys2 && chown core:core /home/core/.ssh/authorized_keys2
  "

  if vagrantConfig['debug']['disable_rsync'] == false
    config.vm.synced_folder ".", "/vagrant", type: "rsync",
      rsync__exclude: [ ".git/", "ezpublish/.git/"],
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

  # caches apt,composer,.. downloads, install with `vagrant plugin install vagrant-cachier`
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
