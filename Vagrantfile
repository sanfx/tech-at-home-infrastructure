# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
PUBLIC_NET_BRIDGE = 'Realtek PCIe GbE Family Controller #5'
SWARM_MASTER_PUBLIC_IP =  "192.168.1.152"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=760, fmode=600"]
  config.vm.box = "minimal/xenial64"
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |v|
    v.customize["modifyvm", :id, "--vram", "2"]
    v.customize["modifyvm", :id, "--cpus", "2"]
    v.customize["modifyvm", :id, "--memory", "2048"]
    v.customize["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize["modifyvm", :id, "--paravirtprovider", "kvm"]
  end

  config.vm.define "swarm-master" do |s|
    s.vm.provision :shell, path: "bootstrap_ansible.sh"
    s.vm.hostname = "swarm-master"
    s.vm.network "public_network", ip: SWARM_MASTER_PUBLIC_IP, auto_config: true, bridge: PUBLIC_NET_BRIDGE
    s.vm.network "private_network", ip: "10.100.192.200"
    s.vm.provider "swarm-master" do |sm|
      sm.customize["modifyvm", :id, "--name", "swarm-master"]
    end

    s.vm.provision "shell", inline: <<-SHELL
    ansible-playbook /vagrant/playbooks/provision.yml
    SHELL

  end

  (1..2).each do |i|
    config.vm.define "swarm-node-#{i}" do |w|
      w.vm.provision :shell, path: "bootstrap_ansible.sh"
      w.vm.hostname = "swarm-node-#{i}"
      w.vm.network "public_network", ip: "192.168.1.20#{i}", auto_config: true, bridge: PUBLIC_NET_BRIDGE
      w.vm.network "private_network", ip: "10.100.192.20#{i}"
      w.vm.provider "swarm-node-#{i}" do |wn|
        wn.customize["modifyvm", :id, "--name", "swarm-node-#{i}"]
      end
      w.vm.provision "shell", inline: <<-SHELL
        apt-get update --fix-missing
        ansible-playbook /vagrant/playbooks/provision.yml
      SHELL
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
     config.cache.scope = :box
  end
end
