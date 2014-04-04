# -*- mode: ruby -*-
# vi: set ft=ruby :

parameters = {
    "ip"        => "33.33.33.33",
    "project"   => "symfony2-docker",
    "memory"    => 2048,
    "cpus"      => 1,
    "timezone"  => "Europe/Warsaw"
}

Vagrant.configure("2") do |config|
  config.vm.box = "saucy64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.provision "docker",
    images: ["ubuntu"]

  config.vm.synced_folder ".", "/vagrant", :nfs => true

  config.vm.network :private_network, ip: parameters['ip']
  config.vm.hostname = parameters['project'] + ".playground"

  config.vm.provider :virtualbox do |vb|
     vb.name = parameters['project']
     vb.gui = false
     vb.customize ["modifyvm", :id, "--memory", parameters['memory']]
     vb.customize ["modifyvm", :id, "--cpus", parameters['cpus']]
   end

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + parameters['timezone'] + "\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

end
