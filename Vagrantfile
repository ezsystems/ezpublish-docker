# -*- mode: ruby -*-
# vi: set ft=ruby :

parameters = {
    "ip"        => "33.33.33.33",
    "project"   => "ezpublish-docker",
    "memory"    => 1024,
    "cpus"      => 1,
    "timezone"  => "CET"
}

Vagrant.configure("2") do |config|
  config.vm.box = "saucy64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box"

  # Pull in the ubuntu base docker image
  config.vm.provision "docker",
    images: ["ubuntu:saucy"]

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + parameters['timezone'] + "\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  # Build the docker images
  config.vm.provision :shell, :inline => "cd /vagrant && ./build.sh"

  # Run the docker image we need
#  config.vm.provision :shell, :inline => "docker run -p 80:80 -v /vagrant/ezpublish/:/srv/ezpublish:rw ezpublish/application:dev"

  config.vm.provision "docker" do |d|
    d.run "web-1",
      image: "ezpublish/application:dev",
      args: "-p 80:80 -v '/vagrant/ezpublish/:/srv/ezpublish:rw'"
  end

  config.vm.synced_folder ".", "/vagrant", :nfs => true

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: parameters['ip']

  config.vm.provider :virtualbox do |vb|
     vb.name = parameters['project']
     vb.gui = false
     vb.customize ["modifyvm", :id, "--memory", parameters['memory']]
     vb.customize ["modifyvm", :id, "--cpus", parameters['cpus']]
  end
end
