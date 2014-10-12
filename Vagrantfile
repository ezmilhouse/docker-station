# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

ENV['VAGRANT_DEFAULT_PROVIDER'] ||= 'docker'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "node" do |app|
    app.vm.provider "docker" do |d|
      d.build_dir  = "./docker/node"
      d.name = 'node'
      d.ports = ['2000:2000']
      d.vagrant_vagrantfile = "./Vagrantfile.proxy"
    end
    app.vm.synced_folder "./project/", "/opt/project/"
  end

  config.vm.define "nginx" do |nginx|
    nginx.vm.provider "docker" do |d|
      d.build_dir  = "./docker/nginx"
      d.name = 'nginx'
      d.vagrant_vagrantfile = "./Vagrantfile.proxy"
      d.link('node:node')
      d.ports = ['80:80']
      # uncomment those lines if you want to attach to container
      #d.cmd = ['/bin/bash', '-l']
      #d.create_args = ['-i', '-t']
      #d.remains_running = false
    end
    nginx.vm.synced_folder "./project/", "/var/www/"
    nginx.vm.synced_folder "./logs/", "/var/www/"
  end

end

