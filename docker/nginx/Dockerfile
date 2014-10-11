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
### NGINX #####################################################################
###############################################################################

RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get install -y nginx
RUN rm -rf /var/lib/apt/lists/*

# set access right for www-data user
RUN chown -R www-data:www-data /var/lib/nginx

# turn off daemon
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# copy default config file from host
ADD ./conf/default /etc/nginx/sites-available/default
ADD ./conf/default /etc/nginx/sites-enabled/default

### FOLDERS ###################################################################
###############################################################################

RUN mkdir -p /var/log
RUN mkdir -p /var/www

### VOLUMES ###################################################################
###############################################################################

VOLUME ["/var/www"]
VOLUME ["/var/log"]
VOLUME ["/etc/nginx/sites-available"]
VOLUME ["/etc/nginx/sites-enabled"]
VOLUME ["/etc/nginx/certs"]
VOLUME ["/etc/nginx/conf.d"]

### COMMAND ###################################################################
###############################################################################

CMD nginx
