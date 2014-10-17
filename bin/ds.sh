#!/bin/sh

# path to local bash's profile settings, mainly used to set `ds` alias
CONFIG_PATH=$HOME/.bash_profile

# default project repo, sample app
DEFAULT_PROJECT_REPO='git@github.com:ezmilhouse/docker-station-app.git'

# default directory where to find docker images in running vagrant box
DEFAULT_DOCKER_IMAGES_ROOT='/vagrant/etc/docker/images'

# mounted root pointing to your local dev dir
DEFAULT_VAGRANT_MOUNTED_ROOT='/vagrant'

DEFAULT_VAGRANT_CONFIG_PATH=~/.bash_profile

# docker container name: --name
DEFAULT_NGINX_CONTAINER_NAME=nginx

# docker container HTTP port
DEFAULT_NGINX_CONTAINER_PORT_HTTP=80

# docker container HTTPS port
DEFAULT_NGINX_CONTAINER_PORT_HTTPS=443

# docker container name: --name
DEFAULT_NODE_CONTAINER_NAME=node

# docker container port: -p
DEFAULT_NODE_CONTAINER_PORT=2000

### GLOBAL: METHODS ###########################################################
###############################################################################

ds_stdout() {
    echo "$1"
}

ds_newlne() {
    echo ""
}

### SCRIPT ####################################################################
###############################################################################

# $ ds [-CONTEXT] [COMMAND] [COMMAND|OPTION] [-FLAG]

case "$1" in

    # SHORTCUTS

    # $ ds down
    down)
        $0 -v sleep
    ;;

    # $ ds init
    init)
        $0 -v new $1
    ;;

    # $ ds list
    list)
        $0 -v list
    ;;

    # $ ds new
    new)
        $0 -p new $1 $2
    ;;

    # $ ds alias
    alias)
        $0 -p alias
    ;;

    # $ ds up
    up)
        $0 -v wake
    ;;

    # $ ds -d
    #
    # Commands in the docker context (-d) are allow you to manage, build, run,
    # your docker containers on a Vagrant machine. There you have to be connected
    # to a running Vagrant box when running commands.
    -d)

        case "$2" in

            # $ ds -d build IMAGE TAG
            ###
            # Builds docker images from IMAGE Dockerfile, tags new built with
            # prefixed local/TAG
            #
            # {req}{str} IMAGE
            #            Valid image name represents folder name in docker
            #            images dir /etc/docker/images
            #
            # {req}{str} TAG
            #            Tag name, you can identify your builds by the tag, in
            #            all lists, prefixed by local/
            ###
            build)

                # validate $3, $4
                if [ ! "$3" -a ! "$4" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameters IMAGE, TAG - build failed."
                    ds_stdout "» USAGE | ds -d build IMAGE TAG"
                    ds_newlne
                    exit 1
                fi

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter IMAGE - build failed."
                    ds_stdout "» USAGE | ds -d build IMAGE TAG"
                    ds_newlne
                    exit 1
                fi

                # validate $3, existing directory
                if [ ! -d "${DEFAULT_DOCKER_IMAGES_ROOT}/$3" ]; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Image /$3 could not be found in ${DEFAULT_DOCKER_IMAGES_ROOT} - build failed."
                    ds_stdout "» USAGE | ds -d build IMAGE TAG"
                    ds_newlne
                    exit 1
                fi

                # validate $4
                if [ ! "$4" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter TAG - build failed."
                    ds_stdout "» USAGE | ds -d build IMAGE TAG"
                    ds_newlne
                    exit 1
                fi

                # build image
                docker build --force-rm=true --rm=true -t local/$4 ${DEFAULT_DOCKER_IMAGES_ROOT}/$3

                # show updated list
                ds_newlne
                $0 -d list -i

                # exit
                ds_stdout "» OK"
                ds_stdout "» Image tagged local/$4 built successfully based on image ${DEFAULT_DOCKER_IMAGES_ROOT}/$3."
                ds_newlne

                exit 0

            ;;

            # $ ds -d build-all
            ###
            # TODO
            # Pretty much work in progress, this is the initial build script
            # that runs, when vagrant provision is done, list of docker containers
            # to be build should come from the outside, for now hardcoded here.
            #
            # Builds all docker images needed for application to run.
            ###
            build-all)

                # build base
                $0 -d build base base

                # build nginx
                $0 -d build nginx nginx

                # build node
                $0 -d build node node

                # exit
                ds_stdout "» OK"
                ds_stdout "» All images build successfully."
                ds_newlne

                exit 0

            ;;

            # $ ds -d clean [-c] [-i]
            ###
            # While working with docker it tends to leave artefacts that you
            # don't use anymore, this command removes all exited containers
            # and all untagged images.
            #
            # {opt}{str} -c
            #            If set, removes all exited containers.
            #
            # {opt}{str} -i
            #            If set, removes all <none> tagged images.
            ###
            clean)

                # normalize
                # if no flags are set, call both recursively, complete cleanup
                if [ ! "$3" ] ; then
                    $0 $1 $2 -c
                    $0 $1 $2 -i
                    exit 0
                fi

                # normalize
                # if both flags are set, call both recursively, complete cleanup
                if [ "$4" ] ; then
                    $0 $1 $2 -c
                    $0 $1 $2 -i
                    exit 0
                fi

                # normalize
                # if only one flag is set, cpecific clean up
                if [ "$3" ] ; then

                    # remove exited containers
                    if [ "$3" = "-c" ]; then

                        # remove exited containers
                        docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker rm -f

                        # show updated list
                        ds_newlne
                        $0 -d list -c

                        # exit
                        ds_stdout "» OK"
                        ds_stdout "» Cleaned up containers successfully."
                        ds_newlne

                        exit 0

                    fi

                    # remove untagged images
                    if [ "$3" = "-i" ]; then

                        # remove images
                        docker rmi -f $(docker images -a | grep "<none>" | awk '{print($3)}') > /dev/null

                        # show updated list
                        ds_newlne
                        $0 -d list -i

                        # exit
                        ds_stdout "» OK"
                        ds_stdout "» Cleaned up images successfully."
                        ds_newlne

                        exit 0

                    fi

                fi

            ;;

            # $ ds -d log CONTAINER
            ###
            # Shows logs of specified docker container in tail -f
            # fashion.
            #
            # {req}{str} CONTAINER
            #            Valid container tag or container id.
            ###
            log)

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter CONTAINER - logs not found."
                    ds_stdout "» USAGE | ds -d log CONTAINER"
                    ds_newlne
                    exit 1
                fi

                ds_newlne
                docker logs -f $3
                ds_newlne

                exit 0;

            ;;

            # $ ds -d list [-c] [-i]
            ###
            # Lists docker assets (containers and images) that are currently
            # in the system, no flags set results in showing both lists.
            #
            # {opt}{str} -c
            #            If set, show all containers.
            #
            # {opt}{str} -i
            #            If set, shows all images.
            ###
            list)

                case "$3" in

                    # ds -d list -c
                    # lists docker containers (that had been run at least once)
                    # maybe --no-trunc
                    -c)
                        ds_newlne
                        docker ps -a
                        ds_newlne
                    ;;

                    # ds -d list -i
                    # lists docker images (that are already built)
                    # maybe --no-trunc
                    -i)
                        ds_newlne
                        docker images
                        ds_newlne
                    ;;

                    # ds -d list
                    # lists both: docker images and containers
                    *)
                        $0 -d list -i
                        $0 -d list -c
                    ;;

                esac

            ;;

            # $ ds -d kill
            ###
            # Stops and removes all running and not running containers,
            # removes all docker images, former setup is completely gone,
            # all docker container data as well. Handle with care!
            ###
            kill)

                # remove all containers
                docker rm -f $(docker ps -a -q)

                # remove all images
                docker rmi $(docker images -a -q)

                # exit
                ds_stdout "» OK"
                ds_stdout "» Killed successfully, all images gone, all containers removed, no data left."
                ds_newlne

                exit 0

            ;;

            # $ ds -d new TAG NAME
            ###
            # Creates a new container for the first time, needs TAG of
            # built image (the container will be based on that image)
            # and a container NAME, that will to identify container
            # further on.
            #
            # {req}{str} TAG
            #            Valid build image tag (without prefix) or
            #            container id.
            # {req}{str} NAME
            #            Choose a container name to identify container
            #            later on.
            ###
            new)

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter TAG - no container created."
                    ds_stdout "» USAGE | ds -d new TAG NAME"
                    ds_newlne
                    exit 1
                fi

                # validate $4
                if [ ! "$4" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter NAME - no container created."
                    ds_stdout "» USAGE | ds -d new TAG NAME"
                    ds_newlne
                    exit 1
                fi

                case "$3" in

                    # TODO
                    # This section is very specific to the built images we what to run,
                    # mounting of directories, ports to run on, it seems that these are
                    # specs to be moved away to higher level config files.

                    # IMAGE: node
                    # starts node container, exposing node application's
                    # port, mounting working dir `/var/www` and log dir
                    # `/var/log/node`
                    node)
                        docker run \
                               --name=$4 \
                               -d \
                               -p ${DEFAULT_NODE_CONTAINER_PORT}:${DEFAULT_NODE_CONTAINER_PORT} \
                               -v /vagrant/var/www:/var/www \
                               -v /vagrant/var/log/node:/var/log/node \
                               local/node \
                               > /dev/null
                    ;;

                    # IMAGE: nginx
                    # starts nginx container, exposing nginx server's
                    # http/https ports, mounting working dir `/var/www`
                    # and log dir `/var/log/nginx`
                    nginx)
                        docker run \
                               --name=$4 \
                               -d \
                               -p ${DEFAULT_NGINX_CONTAINER_PORT_HTTP}:${DEFAULT_NGINX_CONTAINER_PORT_HTTP} \
                               -p ${DEFAULT_NGINX_CONTAINER_PORT_HTTPS}:${DEFAULT_NGINX_CONTAINER_PORT_HTTPS} \
                               -v /vagrant/var/www:/var/www \
                               -v /vagrant/var/log/nginx:/var/log/nginx \
                               local/nginx \
                               > /dev/null
                    ;;

                esac

                # show updated list
                $0 -d list

                # exit
                ds_stdout "» OK"
                ds_stdout "» Container $4 based on local/$3 successfully created."
                ds_newlne

                exit 0

            ;;

            # $ ds -d remove CONTAINER
            ###
            # Removes specified container (running or not), displays
            # updated list of all docker containers available.
            #
            # {req}{str} CONTAINER
            #            Valid container tag or container id.
            ###
            remove)

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter CONTAINER - not stopped."
                    ds_stdout "» USAGE | ds -d stop CONTAINER"
                    ds_newlne
                    exit 1
                fi

                # remove container
                docker rm -f $3 > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» Container $3 successfully removed."
                ds_newlne

            ;;

            # $ ds -d remove-all
            ###
            # Removes all containers (running or not), displays
            # updated list of all docker containers available.
            ###
            remove-all)

                # remove container
                docker rm -f $(docker ps -a -q) > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» All container successfully removed."
                ds_newlne

            ;;

            # $ ds -d restart CONTAINER
            ###
            # Restarts a container that is currently running.
            #
            # {req}{str} CONTAINER
            #            Valid container tag or container id.
            ###
            restart)

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter CONTAINER - restart failed."
                    ds_stdout "» USAGE | ds -d restart CONTAINER"
                    ds_newlne
                    exit 1
                fi

                # stop container
                $0 -d stop $3  > /dev/null

                # start container
                $0 -d start $3 > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» Container $3 successfully restarted."
                ds_newlne

                exit 0;

            ;;

            # $ ds -d restart-all
            ###
            # Restarts all containers that are currently running.
            ###
            restart-all)

                # stop all containers
                $0 -d stop-all > /dev/null

                # start all containers
                $0 -d start-all > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» All container successfully restarted."
                ds_newlne

                exit 0;

            ;;

            # $ ds -d start CONTAINER
            ###
            # Starts a container that was stopped before, means a container
            # that was run before (and then at some point stopped) - you
            # cannot start a unstopped (not yet run) container.
            #
            # {req}{str} CONTAINER
            #            Valid container tag or container id.
            ###
            start)

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter CONTAINER - start failed."
                    ds_stdout "» USAGE | ds -d start CONTAINER"
                    ds_newlne
                    exit 1
                fi

                # start container
                docker start $3 > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» Container $3 successfully started."
                ds_newlne

                exit 0;

            ;;

            # $ ds -d start-all
            ###
            # Starts all containers that were stopped before.
            ###
            start-all)

                # start container
                docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker start

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» All Containers successfully started."
                ds_newlne

                exit 0;

            ;;

            # $ ds -d stop CONTAINER
            ###
            # Stops specified running container, displays updated
            # list of all docker containers available.
            #
            # {req}{str} CONTAINER
            #            Valid container tag or container id.
            ###
            stop)

                # validate $3
                if [ ! "$3" ] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter CONTAINER - not stopped."
                    ds_stdout "» USAGE | ds -d stop CONTAINER"
                    ds_newlne
                    exit 1
                fi

                # stop container
                docker stop -t 0 $3 > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» Docker container $3 successfully stopped."
                ds_newlne

            ;;

            # $ ds -d stop-all
            ###
            # Stops all running containers, displays updated
            # list of all docker containers.
            ###
            stop-all)

                # stop all containers, don't wait for graceful
                # shutdown (-t 0), just kill
                docker ps -a | grep Up | cut -d ' ' -f 1 | xargs docker stop -t 0  > /dev/null

                # show updated list
                $0 -d list -c

                # exit
                ds_stdout "» OK"
                ds_stdout "» All Docker containers stopped."
                ds_newlne

            ;;

        esac

    ;;

    # $ ds -p [PATH]
    #
    # Commands that run on the project level, use them in your local
    # environment to set up your Docker Station project.
    -p)

        case "$2" in

            # $ ds alias
            alias)

                CURRENT_LOCATION=$(pwd)/bin/ds.sh
                CURRENT_CONFIG_PATH=~/.bash_profile

                ds_alias_insert() {

                    ALIAS_NEW=$1

                    # add alias to profile
                    echo "" >> ${CURRENT_CONFIG_PATH}
                    echo "# ALIASES: DOCKER STATION" >> ${CURRENT_CONFIG_PATH}
                    echo "" >> ${CURRENT_CONFIG_PATH}
                    echo "${ALIAS_NEW}" >> ${CURRENT_CONFIG_PATH}

                }

                ds_alias_update() {

                    ALIAS=$1
                    ALIAS_NEW=$2

                    # replacing paths (that contain slashes)
                    # therefore just change the delimiter
                    sed -i -e "s|$ALIAS|$ALIAS_NEW|g" ${CURRENT_CONFIG_PATH}

                }

                ds_alias_set() {

                    ALIAS_NEW="alias ds=${CURRENT_LOCATION}"
                    ALIAS=$(grep -F "ds=" ${CURRENT_CONFIG_PATH})

                    # insert if not set yet
                    if [[ ! "$ALIAS" ]] ; then
                        #echo '-'
                        ds_alias_insert "${ALIAS_NEW}"

                    # update if already set
                    else
                        #echo '+'
                        ds_alias_update "${ALIAS}" "${ALIAS_NEW}"
                    fi

                }

                # invoke setting alias
                ds_alias_set

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Alias set successfully, pointing to: ${CURRENT_LOCATION}"
                ds_stdout "» Please refresh your shell to use new set alias:"
                ds_stdout "» $ . ~/.bash_profile"
                ds_newlne

                exit 0

            ;;

            # ds -p new PATH [REPOSITORY]
            # Creates a new Docker Station project in PATH, a application
            # REPOSITORY is optional, if set ds will clone it into the
            # appropriate directory and runs `npm install` on it. If not
            # set a sample repo will be cloned.
            new)

                if [[ ! "$3" ]] ; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Missing parameter PATH."
                    ds_stdout "» USAGE | ds -p new PATH [REPOSITORY]"
                    ds_newlne
                    exit 1
                fi

                if [ -d "$3" ]; then
                    ds_newlne
                    ds_stdout "» ERROR"
                    ds_stdout "» Directory $3 already exists."
                    ds_stdout "» USAGE | ds -p new PATH [REPOSITORY]"
                    ds_newlne
                    exit 1
                fi

                if [[ ! "$4" ]] ; then

                    ds_newlne
                    ds_stdout "» WARNING"
                    ds_stdout "» No REPOSITORY specified, cloning default project repo."
                    ds_stdout "» USAGE | ds -p new PATH [REPOSITORY]"
                    ds_newlne

                    # fallback to demo repo
                    PROJECT_REPO=${DEFAULT_PROJECT_REPO}

                else

                    # use alternate repo
                    PROJECT_REPO=$4

                fi

                mkdir -p $3 > /dev/null
                mkdir -p $3/bin > /dev/null
                mkdir -p $3/etc > /dev/null
                mkdir -p $3/var > /dev/null
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Project folders created."
                ds_newlne

                cp -r ./bin/* $3/bin > /dev/null
                cp -r ./etc/* $3/etc > /dev/null
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Project folder contents copied."
                ds_newlne

                cp ./Vagrantfile $3/Vagrantfile  > /dev/null
                cp ./.gitignore $3/.gitignore  > /dev/null
                cp ./config.yaml $3/config.yaml  > /dev/null
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Project folder and root files copied."
                ds_newlne

                # TODO
                # at the moment this is a very simple `git clone` feature for
                # the most common use case where you want to clone a app's
                # repository, in the future we should think about local copies,
                # or even symlink solutions (although symlinks might turn out
                # to be evil in docker environments)

                git clone -q ${PROJECT_REPO} $3/var/www > /dev/null
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Application cloned from repo."
                ds_newlne

                cd $3/var/www && npm install --silent > /dev/null
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Application dependencies installed."
                ds_newlne

                # exit
                ds_stdout "» OK"
                ds_stdout "» Project built successfully. Switch to project folder here:"
                ds_stdout "» $ cd $3"
                ds_newlne

                exit 0

            ;;

        esac

    ;;

    # $ ds -v [COMMAND] [COMMAND|OPTION] [-FLAG]
    #
    # Commands taht allow you to handle and manage the Vagrant boxes.
    -v)

        case "$2" in

            # PRIVATE

            # $ ds -v provision
            ###
            # Starts vagrant's provisoning process, based in Vagrantfile
            # in projects root.
            ###
            -provision)

                # provision and up
                vagrant up --provision

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Vagrant box provisioned and up."
                ds_newlne

            ;;

            -provision-bash)

                # provisioon environment
                vagrant ssh -c "${DEFAULT_VAGRANT_MOUNTED_ROOT}/bin/ds.sh -v bash"

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Bash profile set up on vagrant box."
                ds_newlne

            ;;

            # $ ds -v provision-docker
            ###
            # Enters provisioned vagrant box (via ssh) and makes it docker
            # ready, using the ds build
            ###
            -provision-docker)

                # enter, install docker
                vagrant ssh -c "${DEFAULT_VAGRANT_MOUNTED_ROOT}/bin/ds.sh -d build-all"

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Vagrant box successfully provisioned with docker."
                ds_newlne

            ;;

            # PUBLIC

            bash)

                # remove .bash_profiel
                rm ./.bash_profile

                # copy .bash_profile into root
                cp ${DEFAULT_VAGRANT_MOUNTED_ROOT}/etc/docker/images/base/conf/.bash_profile ./.bash_profile

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Bash profile set up on vagrant box. Please reload your bash profile:"
                ds_stdout "» $ . ./.bash_profile"
                ds_newlne

            ;;

            # $ ds -v kill
            ###
            # Destroys the vagrant box in fornt of you.
            ###
            kill)

                # destroy docker contents
                vagrant ssh -c "${DEFAULT_VAGRANT_MOUNTED_ROOT}/bin/ds.sh -d kill"

                # destroy box
                vagrant destroy

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Vagrant box destroyed successfully."
                ds_newlne

                exit 0

            ;;

            # ds -v list
            ###
            # Lists all vagrant boxes on your system, all of them
            ###
            list)

                ds_newlne
                vagrant global-status --prune
                ds_newlne

            ;;

            # $ ds -v new [-f]
            ###
            # TODO:
            # There needs to be more configuration coming from the config.yaml,
            # also there should be config.local.yaml merged into it first.
            #
            # Creates a new vagrant box, provisions box, and builds docker
            # containers on box, reloads box in between to handle known
            # guest addition problems.
            #
            # {opt}{str} -f
            #            If set, destroys a existing box before starting
            #            new one
            ###
            new)

                case "$3" in
                    -f)
                        # detroy box it already exists
                        $0 -v kill
                    ;;
                esac

                # provisioning box
                ds_newlne
                $0 -v -provision
                ds_newlne

                # reloading box
                ds_newlne
                $0 -v -reload
                ds_newlne

                # building docker images
                ds_newlne
                $0 -v -provision-docker

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Vagrant box created successfully. Use ds -v ssh to enter box."
                ds_newlne

                # ssh into box
                vagrant ssh -c "${DEFAULT_VAGRANT_MOUNTED_ROOT}/bin/ds.sh -v bash; /bin/bash"

                exit 0

            ;;

            # $ ds -v reload
            ###
            # Reloads provisioned vagrant box.
            ###
            reload)

                # reloads vagrant box, no provisioning
                vagrant reload

                exit 0

            ;;

            # $ ds -v sleep
            ###
            # Stops all running docker containers on box, tries clean up,
            # exits out of box, puts box on hold. It's the one thing you
            # do when you stop working.
            ###
            sleep)

                # ssh into box, stop docker containers
                vagrant ssh -c "${DEFAULT_VAGRANT_MOUNTED_ROOT}/bin/ds.sh -d stop-all"

                # suspend box
                vagrant halt > /dev/null

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Vagrant box is sleeping now."
                ds_newlne

                exit 0

            ;;

            # $ ds -v ssh
            ###
            # Enters vagrant box via ssh.
            ###
            ssh)

                # ssh into box
                vagrant ssh

                exit 0

            ;;

            # $ ds -v wakeup
            ###
            # Reloads existing vagrant box, enters box via ssh, runs
            # docker logging script in tail -f fashion. This is what
            # you do when you start working.
            ###
            wake)

                # reload box
                vagrant up

                # ssh into box, stop docker containers
                vagrant ssh -c "${DEFAULT_VAGRANT_MOUNTED_ROOT}/bin/ds.sh -d start-all"

                # exit
                ds_newlne
                ds_stdout "» OK"
                ds_stdout "» Vagrant box is awake now."
                ds_newlne

                # ssh back in
                # $0 -v ssh

                exit 0

            ;;

        esac

    ;;

    # $ ds
    *)
        echo ''
        echo '=== DOCKER STATION =============================================='
        echo '=== https://github.com/ezmilhouse/docker-station ================'
        echo ''
        echo 'Usage: ds [options] <command> [<args>]'
        echo ''
        echo 'Shortcuts:'
        echo ''
        echo 'alias   | SHORTCUT: -> ds -p alias'
        echo '        | Sets Docker Station alias to current location.'
        echo '        |'
        echo 'down    | SHORTCUT: -> ds -p alias'
        echo '        | Send Vagrant box to sleep.'
        echo ''       |
        echo 'init    | SHORTCUT: -> ds -v new [-f]'
        echo '        | Provision Vagrant box initially, -f forces destroy'
        echo '        | first.'
        echo '        | '
        echo 'list    | SHORTCUT: -> ds -v list'
        echo '        | Shows a list of all vagrant boxes in the local system.'
        echo '        | '
        echo 'new     | SHORTCUT: -> ds -p new PATH [REPOSITORY]'
        echo '        | Creates new Docker Station project in PATH, clones set'
        echo '        | git repository'
        echo '        |'
        echo 'up      | SHORTCUT: -> ds -v wake'
        echo '        | Wakes up halted, suspended Vagrant box.'
        echo ''
        echo 'Context:'
        echo ''
        echo '-d      | commands in context of Docker containers, images'
        echo '-p      | commands in context of project folders, files'
        echo '-v      | commands in context of Vagrant boxes'
        echo ''
        echo 'Commands:'
        echo ''
        echo '-d      | build'
        echo '        | USAGE: ds -d build <IMAGE> <TAG>'
        echo '        | Builds image from specific Docker IMAGE (Dockerfile),'
        echo '        | tagged with TAG, TAG will be prefixed with local/ namespace.'
        echo '        |'
        echo '        | build-all'
        echo '        | USAGE: ds -d build-all'
        echo '        | Builds a preset of Docker images.'
        echo '        |'
        echo '        | clean'
        echo '        | USAGE: ds -d clean [-c] [-i]'
        echo '        | Tries to clean up Docker artefacts, removes untagged images'
        echo '        | (-i), removes exited containers [-c], might fail sometimes,'
        echo '        | known Docker issue'
        echo '        |'
        echo '        | log'
        echo '        | USAGE: ds -d log CONTAINER'
        echo '        | Shows logs of specific Docker CONATINER (in tail -f style)'
        echo '        |'
        echo '        | list'
        echo '        | USAGE: ds -d list [-c] [-i]'
        echo '        | Lists all available Docker images [-i], containers [-c]'
        echo '        |'
        echo '        | kill'
        echo '        | USAGE: ds -d kill'
        echo '        | Removes all containers, all data will be lost, also removes all'
        echo '        | Docker images, you need to rebuild them afterwards, handle with'
        echo '        | care.'
        echo '        |'
        echo '        | new'
        echo '        | USAGE: ds -d new TAG NAME'
        echo '        | Creates new Docker container based on Docker Image TAG, sets'
        echo '        | container NAME'
        echo '        |'
        echo '        | remove'
        echo '        | USAGE: ds -d remove CONTAINER'
        echo '        | Removes Docker container CONTAINER, running or not.'
        echo '        |'
        echo '        | remove-all'
        echo '        | USAGE: ds -d remove-all'
        echo '        | Removes all Docker containers, running or not.'
        echo '        |'
        echo '        | restart'
        echo '        | USAGE: ds -d restart CONTAINER'
        echo '        | Restarts running Docker container CONTAINER.'
        echo '        |'
        echo '        | restart-all'
        echo '        | USAGE: ds -d restart-all'
        echo '        | Restarts all running Docker containers.'
        echo '        |'
        echo '        | start'
        echo '        | USAGE: ds -d start CONTAINER'
        echo '        | Starts stopped Docker container CONTAINER.'
        echo '        |'
        echo '        | start-all'
        echo '        | USAGE: ds -d start CONTAINER'
        echo '        | Starts all stopped Docker containers.'
        echo '        |'
        echo '        | stop'
        echo '        | USAGE: ds -d stop CONTAINER'
        echo '        | Stops running Docker container CONTAINER.'
        echo '        |'
        echo '        | stop-all'
        echo '        | USAGE: ds -d stop-all'
        echo '        | Starts all stopped Docker containers.'
        echo ''
        echo ''
        echo ''
        echo '-p      | alias'
        echo '        | USAGE: ds -p alias'
        echo '        | Sets global ds alias (in .bash_profile) to current ./bin/ds.sh shell script'
        echo '        |'
        echo '        | new'
        echo '        | USAGE: ds -p new PATH [REPOSITORY]'
        echo '        | Creates new Docker Station project in PATH, copies all files, checks out'
        echo '        | application REPOSITORY (optional, checks out example application if not set)'
        echo ''
        echo ''
        echo ''
        echo '-v      | -provision'
        echo '        | -provision-bash'
        echo '        | -provision-docker'
        echo '        |'
        echo '        | bash'
        echo '        | USAGE: ds -v bash'
        echo '        | Copies /etc/docker/.../.bash_profile from host to Vagrant box, setting'
        echo '        | aliases, you have to source new bash profile manually afterwards with'
        echo '        | $ . ./.bash_profile'
        echo '        |'
        echo '        | kill'
        echo '        | USAGE: ds -v kill'
        echo '        | Destroys Vagrant box and everything on (calls v -d kill on all Docker'
        echo '        | elements before) it, handle with care.'
        echo '        |'
        echo '        | new'
        echo '        | USAGE: ds -v new [-f]'
        echo '        | Provisions a new/existing Vagrant box, including all Docker images,'
        echo '        | containers, based on Vagrantfile and config.yaml. Use optional flag -f'
        echo '        | to kill box first.'
        echo '        |'
        echo '        | reload'
        echo '        | USAGE: ds -v reload'
        echo '        | Reloads existing Vagrant box, booting it up again'
        echo '        |'
        echo '        | sleep'
        echo '        | USAGE: ds -v sleep'
        echo '        | The other half of $ ds -v wake, Stops all Docker containers, then suspends'
        echo '        | (RAM snapshot) Vagrant box. Best way to end the day.'
        echo '        |'
        echo '        | ssh'
        echo '        | USAGE: ds -v ssh'
        echo '        | SSH into vagrant box, no native -c flag.'
        echo '        |'
        echo '        | wake'
        echo '        | USAGE: ds -v wake'
        echo '        | The other half of $ ds -v sleep, ups vagrant box, starts containers.'
        echo ''

    ;;

esac