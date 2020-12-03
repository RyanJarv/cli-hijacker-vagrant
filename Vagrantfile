# -*- mode: ruby -*-
# vi: set ft=ruby :

#require 'aws-sdk-iam'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.hostname = "attacker"

  # This equivalent to having a seperate computer on the same subnet as the host machine.
  config.vm.network "public_network", bridge: "en0: Wi-Fi (Wireless)", use_dhcp_assigned_default_route: true

  # Prevents the guest from running code on the host, unrelated to this demo
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "vagrant", "/vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "512"
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y awscli tcpflow

    ####
    #### NOTE: Use this if I can't demo the improved version of it
    ## sudo wget -L https://github.com/99designs/aws-vault/releases/download/v6.2.0/aws-vault-linux-amd64 -O /usr/local/bin/aws-vault
    ## chmod +x /usr/local/bin/aws-vault
    
    ##
    ## Start new method
    ##
    apt-get install -y build-essential

    pushd $(mktemp -d)
      wget -q https://golang.org/dl/go1.15.5.linux-amd64.tar.gz -O go.tar.gz
      tar -C /usr/local -xzf go.tar.gz
      echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile && source ~/.profile
    popd


    # Assumes this directory is already checked out on the host
    pushd /vagrant/cli-hijacker
      make aws-vault-linux-amd64
      cp aws-vault-linux-amd64 /usr/local/bin/aws-vault
      chmod +x /usr/local/bin/aws-vault
    popd

    ##
    ## End new method
    ##

    echo 'export AWS_VAULT_BACKEND=file' >> ~/.profile
    echo 'export AWS_VAULT_FILE_PASSPHRASE=supersecret' >> ~/.profile

    echo 'cd /vagrant && sudo bash -l' >> ~vagrant/.profile
  SHELL
end
