VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :docker do |docker_config|
    docker_config.vm.box = "geerlingguy/centos7"
    docker_config.vm.hostname = "docker1.example.com"
    docker_config.vm.provision "shell", path: "configure_nodes.sh"
    config.vm.provider "virtualbox" do |v|
       v.memory = 4096
       v.cpus = 1
    end
  end
end
