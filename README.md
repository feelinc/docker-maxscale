# docker-maxscale
Dockerized MaxScale for Galera Cluster.

## Build

    $ chmod +x ./build.sh
    $ ./build.sh
    
## Network
A network is required if you want the maxscale to use galera nodes in the same host.
If you use docker-compose, the network will be created automatically, so will not need to use below command.
If you want to use galera nodes in another host, don't forget to remove the "--net" option below.
## Run

    docker run --interactive --tty --name=galera-maxscale --memory=512m \
        --hostname=galera-maxscale \
        --volume=/path/to/logs:/var/log/maxscale \
        --publish="4006:4006" \
        --publish="4008:4008" \
        --publish="6603:6603" \
        -e HOSTNAME=galera-maxscale \
        -e THREADS=4 \
        -e USER=maxskysql \
        -e PASS=secret \
        -e ENABLE_ROOT_USER=1 \
        -e RW_PORT=4006 \
        -e READ_PORT=4008 \
        -e CLI_PORT=6603 \
        -e CONNECTION_TIMEOUT=600 \
        -e SERVER_LIST=galera-node-master,galera-node-slave-1,galera-node-slave-2 \
        -e BACKEND_PORT=3306 \
        --net=mynetwork_default \
        maxscale:1.0.0

## Environment Defaults
    HOSTNAME=maxscale
    THREADS=4
        Threads for MaxScale to run.
    USER="maxskysql"
        MaxScale User in the cluster.
    PASS="secret"
        MaxScale User password for the cluster.
    ENABLE_ROOT_USER=0
        Allow root access to the DB via MaxScale. Values 0 or 1.
    RW_PORT=4006
        MySQL/MariaDB Port MaxScale is exposing with the READWRITE service.
    READ_PORT=4008
        MySQL/MariaDB Port MaxScale is exposing with the READCONN service.
    CLI_PORT=6603
        MaxScale CLI port.
    CONNECTION_TIMEOUT=600
        Default timeout setting of 600sec/10min. If you need connections to be open for longer, just increase this value to the duration needed. Value is in seconds.
    SERVER_LIST=galera-node-1,galera-node-2,galera-node-3
        List of backend Servers MaxScale is connecting to.
    BACKEND_PORT="3306"
        Port on which the backend servers are listening.
    
    