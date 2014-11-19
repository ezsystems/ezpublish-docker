# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

if !File.exist?( "files/vagrant.yml" )
  FileUtils.cp( "files/vagrant.yml-EXAMPLE", "files/vagrant.yml" )
end
vagrantConfig = YAML::load_file( "files/vagrant.yml" )

Vagrant.configure("2") do |config|
  CLOUD_CONFIG_PATH = "files/user-data"
  $use_aws = false

  if !File.exist?( "files/fig.config" )
      FileUtils.cp( "files/fig.config-EXAMPLE", "files/fig.config" )
  end

  config.vm.provider :aws do |aws, override|
    $use_aws = true

    config.vm.box = "dummy"
    # key for the Vagrant AWS user
    aws.access_key_id = vagrantConfig['aws']['access_key_id']
    aws.secret_access_key = vagrantConfig['aws']['secret_access_key']

    aws.region = vagrantConfig['aws']['region']
    aws.instance_type = vagrantConfig['aws']['instance_type']

    # 10.127.229.0/24 subnet
    aws.subnet_id = vagrantConfig['aws']['subnet_id']
    aws.associate_public_ip = vagrantConfig['aws']['associate_public_ip']

    aws.security_groups = vagrantConfig['aws']['security_groups']

    aws.ami = vagrantConfig['aws']['ami']
    # SSH login credentials
    aws.keypair_name = "Vagrant"
    override.ssh.private_key_path = "files/vagrant.pem"
    override.ssh.username = "core" # should be "admin" for debian images

    if File.exist?(CLOUD_CONFIG_PATH)
        aws.user_data = File.read( CLOUD_CONFIG_PATH );
    end
  end

#  if $use_aws == false
  config.vm.provider :virtaulbox do |vb, override|
      config.vm.box = "coreos-%s" % vagrantConfig['virtualmachine']['coreos_channel']
      config.vm.box_version = ">= 444.5.0"
      config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % vagrantConfig['virtualmachine']['coreos_channel']
  end

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"" + vagrantConfig['virtualmachine']['timezone'] + "\" | sudo tee /etc/timezone"

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
  else
    config.vm.synced_folder ".", "/vagrant", type: "rsync",
      disabled: true
  end

  if File.exist?( "files/auth.json" )
    FileUtils.cp( "files/auth.json", "dockerfiles/ezpublish/prepare" )
  end
  FileUtils.cp( "files/etcd_functions", "dockerfiles/mysql" )

  # Install fig on vagrant machine
  config.vm.provision :shell, :inline => "
    if [ ! -f /opt/bin/fig ]; then \
      mkdir -p /opt/bin
      cp /vagrant/resources/fig /opt/bin
      chmod +x /opt/bin/fig
    fi
  "
  if vagrantConfig['debug']['disable_docker_provision'] == false
    config.vm.provision :shell, :inline => "
      cd /vagrant; \
      ./fig.sh up -d --no-recreate
    "
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

  config.vm.provider :virtualbox do |vb, override|
    if File.exist?(CLOUD_CONFIG_PATH) and $use_aws == false
      config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
      config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
    end
  end

  # Vagrant plugin conflict with coreos
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

end
