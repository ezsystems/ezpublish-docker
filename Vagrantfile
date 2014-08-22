# -*- mode: ruby -*-
# vi: set ft=ruby :

params = {
    "coreos_channel" => "stable",
    "ip" => "33.33.33.53",
    "project" => "ezpublish-docker",
    "memory" => 512,
    "cpus" => 1,
    "timezone" => "CET",
    "db_password" => "youmaychangethis",
    # Generates kickstart.ini file with database settings if true
    "kickstart" => "true",
    # Pre downloads packages from provided url if set for setup wizard speed up
    "packageurl" => "" # "http://packages.ez.no/ezpublish/5.4/5.4.0alpha1/"
}

Vagrant.configure("2") do |config|
  config.vm.box = "coreos-%s" % params['coreos_channel']
  config.vm.box_version = ">= 308.0.1"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % params['coreos_channel']

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + params['timezone'] + "\" | sudo tee /etc/timezone"

  # Pull in the external docker images we need
  config.vm.provision "docker",
    images: ["ubuntu:trusty", "tutum/mysql"]

  config.vm.provision "docker" do |d|
    d.build_image "/vagrant/dockerfiles/apache",          args: "-t 'ezsystems/apache'"
    d.build_image "/vagrant/dockerfiles/apache-php/prod", args: "-t 'ezsystems/apache-php:prod'"
    d.build_image "/vagrant/dockerfiles/apache-php/dev",  args: "-t 'ezsystems/apache-php:dev'"
    #d.build_image "/vagrant/dockerfiles/ezpublish/prod", args: "-t 'ezsystems/ezpublish:prod'"
    d.build_image "/vagrant/dockerfiles/ezpublish/dev",   args: "-t 'ezsystems/ezpublish:dev'"
  end

  # Startup the docker images we need
  config.vm.provision "docker" do |d|
    # todo: we should persist the data to db dir in this folder (see https://github.com/tutumcloud/tutum-docker-mysql)
    d.run "db-1",
      image: "tutum/mysql",
      args: "-e MYSQL_PASS=\""+ params['db_password'] + "\""
    d.run "web-1",
      image: "ezsystems/ezpublish:dev",
      args: "--link db-1:db --dns 8.8.8.8 --dns 8.8.4.4 -p 80:80 -p 22 -v '/vagrant/ezpublish/:/var/www:rw' -e EZ_KICKSTART=\""+ params['kickstart'] +"\" -e EZ_PACKAGEURL=\""+ params['packageurl'] +"\""
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: [ ".git/", "ezpublish/.git/"],
    rsync__auto: true

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: params['ip']

  config.vm.hostname = params['project']

  config.vm.provider :virtualbox do |vb|
     vb.check_guest_additions = false
     vb.functional_vboxsf = false
     vb.gui = false
     vb.memory = params['memory']
     vb.cpus = params['cpus']
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
