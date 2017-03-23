FROM centos:7
MAINTAINER Sulaeman <me@sulaeman.com>

# We set some defaults for config creation. Can be overwritten at runtime.
ENV HOSTNAME=maxscale \
    THREADS=4 \
    USER="maxskysql" \
    PASS="secret" \
    ENABLE_ROOT_USER=0 \ 
    RW_PORT=4006 \
    READ_PORT=4008 \
    CLI_PORT=6603 \
    CONNECTION_TIMEOUT=600 \
    SERVER_LIST="" \
    BACKEND_PORT="3306"

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && yum -y install https://downloads.mariadb.com/enterprise/yzsw-dthq/generate/10.0/mariadb-enterprise-repository.rpm \
    && yum -y update \
    && yum -y install maxscale \
    && yum clean all \
    && rm -rf /tmp/*

# We copy our config creator script to the container
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# EXPOSE the MaxScale default ports

## RW Split Listener
EXPOSE $RW_PORT

## Read Connection Listener
EXPOSE $READ_PORT

## CLI Listener
EXPOSE $CLI_PORT

# We define the config creator as entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# We startup MaxScale as default command
CMD ["/usr/bin/maxscale", "-d"]
