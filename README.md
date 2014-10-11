## Intro
I had a pretty hard time to setup a development environment for my Node.js applications, locally on Mac OSX, using Vagrant and Docker. 

I finally got it running. I hope this repo will help you to build your own.

## When done ...

... with the setup, you'll have a running NGINX/Node.js sample application, all in Docker containers on a Vagrant host, you can access your app in the Browser by going to `http://example.com`.

## Installation
- Install [Vagrant](https://www.vagrantup.com/downloads.html) - nothing special here.
- Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) - nothing special here.

## Project

#### 1. Checkout this repo

```
$ mkdir -p /var/www/projects
$ git clone git@github.com:ezmilhouse/docker.git example.com
```

#### 2. Go to project dir, create Vagrant box
```
$ cd /var/www/projects/example.com
$ vagrant up app --provision

# Virtualbox Guest Additions demand a reload
$ vagrant reload
```

This will take a few minutes, as this is the initial `vagrant up` and therefore the first provisioning of your box.

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

#### 4. Add entry to Mac OSX `hosts` file

```
# if you're still on the box, leave it for now
vagrantbox$ exit

# edit hosts file
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



