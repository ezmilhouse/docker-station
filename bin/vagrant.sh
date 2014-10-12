#!/bin/sh
case "$1" in
	*)
		cp /vagrant/etc/docker/images/base/conf/.bash_profile ~/.bash_profile > /dev/null
		. ~/.bash_profile > /dev/null
		echo "ok!"
		echo "Now SSH into your Vagrant box and start Docker Station:"
		echo "==> $ vagrant ssh"
		echo "==> $ ds start"
		;;
esac