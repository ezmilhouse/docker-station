Vagrant.configure("2") do |config|

  config.vm.define "app" do |m|

    # set up basic box image
    m.vm.box = "ubuntu/trusty64"

    # set host name
    m.vm.hostname = "example.com"

    # set private network, machine will use this ip
    m.vm.network "private_network", ip: "192.168.33.10"

    # provision docker environment
    m.vm.provision "docker"

    # provision docker base image
    m.vm.provision "shell", path: "./bin/vagrant.provision.sh"

  end

end