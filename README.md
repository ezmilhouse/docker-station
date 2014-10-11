## Intro
I had a pretty hard time to setup a development environment for my Node.js applications, locally on Mac OSX, using Vagrant and Docker. 

I finally got it running. I hope this repo will help you to build your own.

## When done ...

... with the setup, you'll have a running NGINX/Node.js sample application, all in Docker containers on a Vagrant host, you can access your app in the Browser by going to `http://example.com`.

Your project directory will be mounted into Vagrant, so you can develop locally and your changes are automatically available in the respective Docker containers. 

The Node.js app itself is run by `nodemon`, so the Node.js process will be restarted automatically once `nodemon` detects changes.

## Installation
I assume that [Node.js & NPM](http://nodejs.org/download/) are already installed on your system - so let's get ready for Vagrant.

- install [Vagrant](https://www.vagrantup.com/downloads.html)
- install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)

## Project

#### 1. Checkout this repo

```
$ mkdir -p /var/www/projects
$ git clone git@github.com:ezmilhouse/docker.git example.com
```

This repo contains a sample app that needs some `NPM` love:

```
$ cd /var/www/projects/example.com/var/www
$ npm install
```

#### 2. Go to project dir, create Vagrant box
```
$ cd /var/www/projects/example.com
$ vagrant up app --provision

# Virtualbox Guest Additions demand a reload
$ vagrant reload app
```

This will take a few minutes, as this is the initial `vagrant up` and therefore the first provisioning of your box.

##### What is happening here?
> The `Vagrantfile` let's you define the network for your Vagrant box, so the IP we're using in the following steps is set here - change it if you like.  

> Vagrant will check the `Vagrantfile` form this repo's root directory to create a Vagrant box. Take a look at the file - the box will be provisioned for the use with Docker and afterwards a bootstrapping provision script `./bin/vagrant.provision.sh` is called. That script is initiating the building of 3 Docker images: 
- a basic Ubuntu image
- one for Node.js
- one for NGINX  

> The Docker images are defined by `Dockerfile(s)`, take a look at them in `/etc/docker/images` - make changes as you like.

#### 3. Start Docker containers for NGINX and Node.js

```
# ssh into your box
$ vagrant ssh app
```

```
# on the box, start containers
vagrantbox$ /vagrant/bin/env.sh start

# see them running
vagrantbox$ /vagrant/bin/env.sh state
```

Now you can enter your app in your browser by going to [http://192.168.33.10](http://192.168.33.10). 

##### What is happening here?
> Docker is installed on your Vagrant box so you cann use Docker the way you're used to it after you ssh to the boy, you could run `$ docker ps -a` on the box - to make your life easier you can find a little management script in `/bin/env.sh` that provides some handy shortcuts to start, stop or restart your Docker containers on the box.
```
# start all containers
$ /vagrant/bin/env.sh start

> # stop all containers
$ /vagrant/bin/env.sh stop 

> # restart all containers
$ /vagrant/bin/env.sh restart 

> # show STDOUT of container
$ /vagrant/bin/env.sh log [CONTAINER]

> # show list of running containers
$ /vagrant/bin/env.sh state 
```

#### 4. Add entry to Mac OSX `hosts` file

```
# if you're still on the box, leave it for now
vagrantbox$ exit

# edit hosts file, save & exit (Ctrl-x, y)
$ sudo nano /etc/hosts
```

Add line:

```
192.168.33.10    example.com
```

Save and flush host cache:
```
$ dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

Go to your browser, enter [http://example.com](http://example.com) - brilliant.

#### 5. Make changes, feel the magic

Finally you're app is running in Docker containers, those, are hosted by a Vagrant box, and your project dir is synced to your local Mac OS file system.

Let's make some changes ...

- open the `index.js` in your app's working dir: `/var/www/projects/example.com/var/www`
- change the `res.send('Hello World!');` into `res.send('Hello Planet!');`
- refresh browser at `http://example.com`

Have fun!


