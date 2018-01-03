#!/bin/bash

set -eu

ARGS="$@"

MIN_DOCKER_VERSION=1.6.0

# check database dir
check_db_dir() {
	if [ ! -d ~/.lsn_base/_db93 ]; then
	  mkdir ~/.lsn_base/_db93
	fi
    if [ ! -d ~/.lsn_base/_db94 ]; then
      mkdir ~/.lsn_base/_db94
    fi
    if [ ! -d ~/.lsn_base/_db95 ]; then
      mkdir ~/.lsn_base/_db95
    fi
}

#check docker version
check_docker_version() {
    if ! DOCKER_VERSION=$(docker -v | sed -n 's%^Docker version \([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\).*$%\1%p') ||
       [ -z "$DOCKER_VERSION" ] ; then
        echo "ERROR: Docker not found --> please install docker" >&2
        exit 1
    fi

    DOCKER_VERSION_MAJOR=$(echo "$DOCKER_VERSION" | cut -d. -f 1)
    DOCKER_VERSION_MINOR=$(echo "$DOCKER_VERSION" | cut -d. -f 2)
    DOCKER_VERSION_PATCH=$(echo "$DOCKER_VERSION" | cut -d. -f 3)

    MIN_DOCKER_VERSION_MAJOR=$(echo "$MIN_DOCKER_VERSION" | cut -d. -f 1)
    MIN_DOCKER_VERSION_MINOR=$(echo "$MIN_DOCKER_VERSION" | cut -d. -f 2)
    MIN_DOCKER_VERSION_PATCH=$(echo "$MIN_DOCKER_VERSION" | cut -d. -f 3)

    if [ \( "$DOCKER_VERSION_MAJOR" -lt "$MIN_DOCKER_VERSION_MAJOR" \) -o \
        \( "$DOCKER_VERSION_MAJOR" -eq "$MIN_DOCKER_VERSION_MAJOR" -a \
        \( "$DOCKER_VERSION_MINOR" -lt "$MIN_DOCKER_VERSION_MINOR" -o \
        \( "$DOCKER_VERSION_MINOR" -eq "$MIN_DOCKER_VERSION_MINOR" -a \
        \( "$DOCKER_VERSION_PATCH" -lt "$MIN_DOCKER_VERSION_PATCH" \) \) \) \) ] ; then
        echo "ERROR: lsn_base requires Docker version $MIN_DOCKER_VERSION or later; you are running $DOCKER_VERSION" >&2
        exit 1
    fi
}

check_dns_resolver(){
	if [ ! -d /etc/resolver ]; then
		echo "Creating DNS resolver dir"
	  	sudo mkdir /etc/resolver
	fi
	if [ ! -f /etc/resolver/dev ]; then
		echo "Creating DNS resolver for .dev domain"
	  	sudo touch /etc/resolver/dev
        sudo bash -c "echo -e \"nameserver 127.0.0.1\nport 5300\" >> /etc/resolver/dev"
      fi
}

start_docker_containers(){
	( cd ~/.lsn_base && docker-compose up --build -d )

}

stop_docker_containers(){
	( cd ~/.lsn_base && docker-compose stop )
}

kill_docker_containers(){
	( cd ~/.lsn_base && docker-compose kill )
}

usage() {
    echo "Usage:"
    echo "setup.sh start"
    echo "setup.sh stop"
    exit 1
}

##MAIN
[ $# -gt 0 ] || usage
COMMAND=$1
shift 1

check_db_dir
check_docker_version

case "$COMMAND" in
    help)
	usage
        ;;

    start)
#	check_dns_resolver
	start_docker_containers
        ;;

    stop)
	stop_docker_containers
        ;;

    *)
        echo "Unknown command '$COMMAND'" >&2
        usage
        ;;

esac

