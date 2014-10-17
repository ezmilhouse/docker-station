Docker Station
======
The `Docker Station` is a boilerplate project to create a local development environment for running [Node.js](http://nodejs.org/) applications under [nginx](http://nginx.org/) in [Docker](https://www.docker.com/) containers - all hosted on [Vagrant](https://www.vagrantup.com/) virtual machines, therefore ready-to-use on Mac OS X.

**Before we start ...**  
It's still early in the project - there might be bugs and lots of stuff to improve - anyway it's a start. Let me know if you you find something, just hammer the issues section.

## Dependencies
Please make sure you have the following prerequisites installed:

- [Node.js & NPM](http://nodejs.org/download/)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Quickstart

#### 1. Create Project

Create new project, folder will be created in path, git repo will be cloned, repository is optional, leave it out, and a boilerplate app will be cloned.

```
$ ./bin/ds.sh new /var/www/app git@github.com:ezmilhouse/docker-station-app.git
$ cd app
```

Set the `ds` alias to this project. NOw you can move on using the `ds` alias instead of `./bin/ds.sh` full path.
```
$ ./bin/ds.sh alias
$ . ~/.bash_profile
```

Open `config.yaml`, edit project configuration as you please.

```
VAGRANT_HOST_IP      : '192.168.33.10'
VAGRANT_HOST_NAME    : 'test.com'
VAGRANT_BOX_NAME     : 'app'
VAGRANT_BASH_PROFILE : './etc/docker/images/base/conf/.bash_profile'
```

#### 2. Provision Vagrant & Docker

Provision Vagrant box, start Docker containers, run app.

```
$ ds -v new
```

The first time running this will take a few minutes. 

When done, open your browser and see your app running at: [http://192.168.33.10](http://192.168.33.10). 

#### 3. /etc/hosts - Set Host

In a last step you can add a new entry `192.168.33.10 test.com` to your list of hosts in `/etc/hosts` (and flush host cache afterwards). Make sure that you lock out of the running Vagrant box first.

```
$ exit
$ sudo nano /etc/hosts
# 192.168.33.10 test.com
$ dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

See your app running on [http://test.com](http://test.com) now.

#### 4. Go Develop

Finally your app is running in Docker containers, the containers are hosted on a Vagrant box, and your project dir is synced to your local Mac OS X file system.

Let's start developing and make some changes:

- open the `index.js` in `/var/www`in your project folder.
- change the `res.send('Hello World!');` into `res.send('Hello Planet!');`
- refresh browser at [http://test.com](http://test.com)
- it's automatically updated

## CLI 
Use the `ds` CLI to run, stop, manage your box and containers.

```
=== DOCKER STATION ==============================================
=== https://github.com/ezmilhouse/docker-station ================

Usage: ds [options] <command> [<args>]

Shortcuts:

alias   | SHORTCUT: -> ds -p alias
        | Sets Docker Station alias to current location.

down    | SHORTCUT: -> ds -p alias
        | Send Vagrant box to sleep.

init    | SHORTCUT: -> ds -v new [-f]
        | Provision Vagrant box initially, -f forces destroy
        | first.

project | SHORTCUT: -> ds -p new PATH [REPOSITORY]

up      | SHORTCUT: -> ds -v wake
        | Wakes up halted, suspended Vagrant box.

Context:

-d      | commands in context of Docker containers, images
-p      | commands in context of project folders, files
-v      | commands in context of Vagrant boxes

Commands:

-d      | build
        | USAGE: ds -d build <IMAGE> <TAG>
        | Builds image from specific Docker IMAGE (Dockerfile),
        | tagged with TAG, TAG will be prefixed with local/ namespace.
        |
        | build-all
        | USAGE: ds -d build-all
        | Builds a preset of Docker images.
        |
        | clean
        | USAGE: ds -d clean [-c] [-i]
        | Tries to clean up Docker artefacts, removes untagged images
        | (-i), removes exited containers [-c], might fail sometimes,
        | known Docker issue
        |
        | log
        | USAGE: ds -d log CONTAINER
        | Shows logs of specific Docker CONATINER (in tail -f style)
        |
        | list
        | USAGE: ds -d list [-c] [-i]
        | Lists all available Docker images [-i], containers [-c]
        |
        | kill
        | USAGE: ds -d kill
        | Removes all containers, all data will be lost, also removes all
        | Docker images, you need to rebuild them afterwards, handle with
        | care.
        |
        | new
        | USAGE: ds -d new TAG NAME
        | Creates new Docker container based on Docker Image TAG, sets
        | container NAME
        |
        | remove
        | USAGE: ds -d remove CONTAINER
        | Removes Docker container CONTAINER, running or not.
        |
        | remove-all
        | USAGE: ds -d remove-all
        | Removes all Docker containers, running or not.
        |
        | restart
        | USAGE: ds -d restart CONTAINER
        | Restarts running Docker container CONTAINER.
        |
        | restart-all
        | USAGE: ds -d restart-all
        | Restarts all running Docker containers.
        |
        | start
        | USAGE: ds -d start CONTAINER
        | Starts stopped Docker container CONTAINER.
        |
        | start-all
        | USAGE: ds -d start CONTAINER
        | Starts all stopped Docker containers.
        |
        | stop
        | USAGE: ds -d stop CONTAINER
        | Stops running Docker container CONTAINER.
        |
        | stop-all
        | USAGE: ds -d stop-all
        | Starts all stopped Docker containers.



-p      | alias
        | USAGE: ds -p alias
        | Sets global ds alias (in .bash_profile) to current ./bin/ds.sh shell script
        |
        | new
        | USAGE: ds -p new PATH [REPOSITORY]
        | Creates new Docker Station project in PATH, copies all files, checks out
        | application REPOSITORY (optional, checks out example application if not set)



-v      | -provision
        | -provision-bash
        | -provision-docker
        |
        | bash
        | USAGE: ds -v bash
        | Copies /etc/docker/.../.bash_profile from host to Vagrant box, setting
        | aliases, you have to source new bash profile manually afterwards with
        | $ . ./.bash_profile
        |
        | kill
        | USAGE: ds -v kill
        | Destroys Vagrant box and everything on (calls v -d kill on all Docker
        | elements before) it, handle with care.
        |
        | new
        | USAGE: ds -v new [-f]
        | Provisions a new/existing Vagrant box, including all Docker images,
        | containers, based on Vagrantfile and config.yaml. Use optional flag -f
        | to kill box first.
        |
        | reload
        | USAGE: ds -v reload
        | Reloads existing Vagrant box, booting it up again
        |
        | sleep
        | USAGE: ds -v sleep
        | The other half of $ ds -v wake, Stops all Docker containers, then suspends
        | (RAM snapshot) Vagrant box. Best way to end the day.
        |
        | ssh
        | USAGE: ds -v ssh
        | SSH into vagrant box, no native -c flag.
        |
        | wake
        | USAGE: ds -v wake
        | The other half of $ ds -v sleep, ups vagrant box, starts containers.
```

##  Project Directory Layout
After checking out `Docker Station` and running `./bin/ds.sh new ...` to [initiate]() your project - it will have following directory layout. 

#### /
```
# configuration files

| .gitignore
| config.yaml 
| Vagrantfile  
```

#### /bin
```
# shell scripts to provision and manage your box
# and docker containers

├── bin  
│   └── ds.sh
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


