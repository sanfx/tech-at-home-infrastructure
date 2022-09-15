# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
PUBLIC_NET_BRIDGE = 'Realtek PCIe GbE Family Controller #5'
SWARM_WORKER_NODE_IP =  "192.168.1.202"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=777,fmode=770"]
  config.vm.synced_folder "./mysql", "/mysql", mount_options: ["dmode=777,fmode=777,uid=132,gid=132"]
  config.vm.synced_folder "./nextcloud", "/nextcloud", mount_options: ["dmode=770,fmode=770,uid=33,gid=33"]
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = true
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--vram", "2"]
    v.customize ["modifyvm", :id, "--memory", "2048"]
  end

  (0..1).each do |i|
    config.vm.define "swarm-master-#{i}" do |s|
      s.vm.provision :shell, path: "bootstrap_ansible.sh"
      s.vm.hostname = "swarm-master-#{i}"
      s.vm.network "public_network", ip:  "192.168.1.20#{i}", auto_config: true, bridge: PUBLIC_NET_BRIDGE
      s.vm.network "private_network", ip: "10.100.192.20#{i}"

      s.vm.provider "swarm-master-#{i}" do |sm|
        sm.customize["modifyvm", :id, "--cpus", "2"]
        sm.customize["modifyvm", :id, "--natdnshostresolver1"]
        sm.customize["modifyvm", :id, "--name", "swarm-master-#{i}"]
      end
      s.vm.provision "shell", inline: <<-SHELL
      ansible-playbook /vagrant/provision.yml
      SHELL
    end
  end

  config.vm.define "swarm-worker-node" do |w|
    w.vm.provision :shell, path: "bootstrap_ansible.sh"
    w.vm.hostname = "swarm-worker-node"
    w.vm.network "public_network", ip: SWARM_WORKER_NODE_IP, auto_config: true, bridge: PUBLIC_NET_BRIDGE
    w.vm.network "private_network", ip: "10.100.192.202"
    w.vm.provider "swarm-worker-node" do |wn|
      wn.customize["modifyvm", :id, "--paravirtprovider", "kvm"]
      wn.customize["modifyvm", :id, "--cpus", "1"]
      wn.customize["modifyvm", :id, "--memory", "1024"]
      wn.customize["modifyvm", :id, "--name", "swarm-worker-node"]
    end

    w.vm.provision "shell", inline: <<-SHELL
      apt-get update --fix-missing
      ansible-playbook /vagrant/provision.yml
    SHELL
  end

  if Vagrant.has_plugin?("vagrant-cachier")
     config.cache.scope = :box
  end
end
