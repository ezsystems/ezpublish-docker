# -*- mode: ruby -*-
# vi: set ft=ruby :

params = {
    "ip"          => "33.33.33.53",
    "project"     => "ezpublish-docker",
    "memory"      => 1024,
    "cpus"        => 1,
    "timezone"    => "CET",
    "db_password" => "youmaychangethis",
    "ez_kickstart" => "true"
}

Vagrant.configure("2") do |config|
  config.vm.box = "trusty64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  # Pull in the external docker images we need
  config.vm.provision "docker",
    images: ["tianon/ubuntu-core:14.04", "tutum/mysql"]
#    images: ["ubuntu:trusty", "tutum/mysql"]

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + params['timezone'] + "\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  # Build images of our custom docker files
  config.vm.provision :shell, :inline => "cd /vagrant && ./build.sh"

  # Startup the docker images we need
  config.vm.provision "docker" do |d|
    # todo: we should persist the data to db dir in this folder (see https://github.com/tutumcloud/tutum-docker-mysql)
    d.run "db-1",
      image: "tutum/mysql",
      args: "-e MYSQL_PASS=\""+ params['db_password'] + "\""
    d.run "web-1",
      image: "ezsystems/ezpublish:dev",
      args: "--link db-1:db -n -p 80:80 -p 22 -v '/vagrant/ezpublish/:/var/www:rw' -e EZ_KICKSTART=\""+ params['ez_kickstart'] + "\""
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: [ ".git/", ".vagrant/", "ezpublish/.git/"],
    rsync__auto: true

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: params['ip']

  config.vm.provider :virtualbox do |vb|
     vb.name = params['project']
     vb.gui = false
     vb.customize ["modifyvm", :id, "--memory", params['memory']]
     vb.customize ["modifyvm", :id, "--cpus", params['cpus']]
     vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
  end

  # caches apt,composer,.. downloads, install with `vagrant plugin install vagrant-cachier`
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
