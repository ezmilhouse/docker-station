#!/bin/sh
case "$1" in
	init)
		cd var/www && npm install
		vagrant up app --provision
		vagrant reload app
		;;
	*)
		cp /vagrant/etc/docker/images/base/conf/.bash_profile ~/.bash_profile && . ~/.bash_profile
		echo "ok!"
		echo "Now SSH into your Vagrant box and start Docker Station:"
		echo "==> $ vagrant ssh"
		echo "==> $ ds start"
		;;
esac