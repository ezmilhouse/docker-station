#!/bin/sh

### ENVIRONMENT ###############################################################
###############################################################################

# mounted root
DIR='/vagrant'

# mounted images folder
DIR_DOCKER='/vagrant/etc/docker/images'

### PROVISION #################################################################
###############################################################################

echo 'Building general docker Ubuntu image ...'
docker build -t local/base ${DIR_DOCKER}/base

echo 'Building general docker NGINX image ...'
docker build -t local/nginx ${DIR_DOCKER}/nginx

echo 'Building general docker Node.js image ...'
docker build -t local/node ${DIR_DOCKER}/node

echo 'All done ... ok!'