#!/bin/sh

### ENVIRONMENT ###############################################################
###############################################################################

# mounted root
DIR='/vagrant'

# mounted images folder
DIR_DOCKER='/vagrant/etc/docker/images'

### CONTAINER: NGINX ##########################################################
###############################################################################

# docker container name: --name
NGINX_CONTAINER_NAME=nginx

# docker container port: -p
NGINX_CONTAINER_PORT=80

### CONTAINER: NODE ###########################################################
###############################################################################

# docker container name: --name
NODE_CONTAINER_NAME=node

# docker container port: -p
NODE_CONTAINER_PORT=2000

### SCRIPT ####################################################################
###############################################################################

case "$1" in
	log)
		case "$2" in
			nginx)
				docker logs -f $2
				;;
			node)
				docker logs -f $2
				;;
			*)
				docker logs -f "node"
				;;
		esac
	;;
	clean)
		echo '==> Removing exited containers ...'
		docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker rm -f > /dev/null
	;;
	state)
		docker ps -a --no-trunc=false
	;;
	start)
		e clean
		echo '==> Starting ...'
		echo '==> docker: ---> container: '${NGINX_CONTAINER_NAME}
		docker run -d -p ${NGINX_CONTAINER_PORT}:${NGINX_CONTAINER_PORT} --name=nginx -v /vagrant/var/www:/var/www -v /vagrant/var/log/nginx:/var/log/nginx local/nginx > /dev/null
		echo '==> docker: ---> container: '${NODE_CONTAINER_NAME}
		docker run -d -p ${NODE_CONTAINER_PORT}:${NODE_CONTAINER_PORT}  --name=node -v /vagrant/var/www:/var/www -v /vagrant/var/log/node:/var/log/node local/node > /dev/null
		echo '==> ok!'
		echo ''
		docker ps -a
		echo ''
		/vagrant/bin/env.sh log
		;;
	stop)
		echo ''
		echo '==> Stopping ...'
		docker stop $(docker ps -a -q) > /dev/null
		echo '==> ok!'
		;;
	restart)
		e stop
		e start
		;;
	*)
		echo 'Try start, stop or restart'
		;;
esac