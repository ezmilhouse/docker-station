require "yaml"
vconfig = YAML.load(File.open(File.join(File.dirname(__FILE__), "config.yaml"), File::RDONLY).read)

Vagrant.configure("2") do |config|

  config.vm.define vconfig['VAGRANT_BOX_NAME'] do |m|

    # set up basic box image
    m.vm.box = "ubuntu/trusty64"

    # set host name
    m.vm.hostname = vconfig['VAGRANT_HOST_NAME']

    # set private network, machine will use this ip
    m.vm.network "private_network", ip: vconfig['VAGRANT_HOST_IP']

    # provision docker environment
    m.vm.provision "docker"

    # provision docker images
    m.vm.provision "shell", path: "./bin/ds.sh", args: "-d build-all"

    # provision docker containers
    m.vm.provision "shell", path: "./bin/ds.sh", args: "-d new node node"
    m.vm.provision "shell", path: "./bin/ds.sh", args: "-d new nginx nginx"

  end

end