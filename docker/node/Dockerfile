FROM ubuntu:14.04

### PACKAGE MANAGER ###########################################################
###############################################################################

RUN apt-get update

RUN apt-get install -y \
    build-essential \
    curl \
    gcc \
    git \
    git-core \
    make \
    nano \
    python-software-properties \
    software-properties-common

### NODE ######################################################################
###############################################################################

# because of the well documented naming conflict with the
# Amateur Packet Radio Node Program use alternatives here
RUN apt-get install -y nodejs
RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
RUN apt-get install -y npm

# install modules globally
RUN npm install -g \
    commander \
    forever \
    grunt \
    mocha \
    nodemon \
    node-inspector \
    phantomjs

### VOLUMES ###################################################################

VOLUME ["/opt/project/"]
WORKDIR /opt/project/

### COMMAND ###################################################################

# run node application (in legacy mode)
CMD nodemon -L index.js
