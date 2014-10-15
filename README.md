Docker Station
======
The `Docker Station` is a boilerplate project to create a local development environment for running [Node.js](http://nodejs.org/) applications under [nginx](http://nginx.org/) in [Docker](https://www.docker.com/) containers - all hosted on [Vagrant](https://www.vagrantup.com/) virtual machines, therefore ready-to-use on Mac OS X.

## Dependencies
Please make sure you have the following prerequisites installed:

- [Node.js & NPM](http://nodejs.org/download/)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Quickstart

#### 1. Create Project
```
# checkout ds
$ git clone git@github.com:ezmilhouse/docker-station.git tmp
```

```
# create ds project
$ ./bin/ds.sh -n app -p /path/to/project -r user/repo -i 192.168.33.10 -p 2000
```
Now open your browser and see your app running at: [http://192.168.33.10](http://192.168.33.10)

#### 2. Create Host Entry
Add a new host entry to your `/etc/hosts` file:

```
# add host entry
$ sudo /etc/hosts >> 192.168.33.10 example.com

# flush host cache
$ dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```
Now open your browser and see your app running at [http://example.com](http://example.com)

##  Project Directory Layout
After checking out `Docker Station` and running `./bin/ds.sh` to [initiate]() your project - it will have following directory layout. 

#### /bin
```
# shell scripts to provision and manage your box
# and docker containers

├── bin  
│   └── ds.sh
│   └── ds.provision.sh
```

#### /etc
```
# all the docker images supported at this pointn in
# time, more images will be added 

├── etc  
│   └── docker
│   │   └── images
│   │   │   └── base
│   │   │   │   │ Dockerfile
│   │   │   └── mongo
│   │   │   │   └── conf
│   │   │   │   │ Dockerfile
│   │   │   └── ...
```   

#### /var
```
# holds all Vagrant mounted directories and Docker 
# Volumes, it's the persistent layer of your dev 
# environment

├── var  
│   └── data
│   │   └── mongo
│   │   └── ...
│   └── log
│   │   └── mongo
│   │   └── ...
│   └── www
│   │   └── [YOUR_APPLICATION_FILES]
```




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
$ git clone git@github.com:ezmilhouse/docker-station.git example.com
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

> Vagrant will check the `Vagrantfile` from this repo's root directory to create a Vagrant box. Take a look at the file - the box will be provisioned for the use with Docker and afterwards a bootstrapping provision script `./bin/vagrant.provision.sh` is called. That script is initiating the building of 3 Docker images: 
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
vagrantbox$ ds start

# see them running
vagrantbox$ ds state
```

Now you can enter your app in your browser by going to [http://192.168.33.10](http://192.168.33.10). 

##### What is happening here?
> Docker is installed on your Vagrant box so you can use Docker the way you're used to it (via it's CLI) when you're connected to the box via `vagrant ssh` - ex: you can run `$ docker ps -a` on the box - just to make your life easier there is a little management script in `/bin/docker.station.sh` that provides some handy shortcuts to start, stop or restart your Docker containers on the box.
```
# start all containers
$ ds start

> # stop all containers
$ ds stop 

> # restart all containers
$ ds restart 

> # show STDOUT of container
$ ds log [CONTAINER]

> # show list of running containers
$ ds state 
```

#### 4. Add entry to Mac OS X `hosts` file

```
# if you're still on the box, leave it for now
vagrantbox$ exit

# edit hosts file, save & exit (Ctrl-x, y)
$ sudo nano /etc/hosts
```

Add line (use the IP set in our `Vagrantfile`):

```
192.168.33.10    example.com
```

Save and flush host cache:
```
$ dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

Go to your browser, enter [http://example.com](http://example.com) - brilliant.

#### 5. Make changes, feel the magic

Finally your app is running in Docker containers, the containers are hosted on a Vagrant box, and your project dir is synced to your local Mac OS X file system.

Let's start developing and make some changes:

- open the `index.js` in your app's working dir: `/var/www/projects/example.com/var/www`
- change the `res.send('Hello World!');` into `res.send('Hello Planet!');`
- refresh browser at `http://example.com`

Have fun!


