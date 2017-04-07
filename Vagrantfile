# -*- mode: ruby -*-
# vi: set ft=ruby :
 
VAGRANTFILE_API_VERSION = "2"
NODE_COUNT = 1
 
INTNET_NAME = [*('A'..'Z')].sample(8).join
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus", 2]
  end
  config.vm.provision :shell, :path => "configure_nodes.sh"
 
  NODE_COUNT.times do |i|
    node_id = "node#{i}"
    config.vm.define node_id do |node|
      node.vm.box = "geerlingguy/centos7"
      node.vm.hostname = "#{node_id}.docker.home"
      node.vm.network "private_network", ip: "192.168.20.1#{i}"
    end
  end
 
 
end
