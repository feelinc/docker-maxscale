#!/bin/bash

set -e

# if service discovery was activated, we overwrite the SERVER_LIST with the
# results of DNS service lookup
if [ -n "$DB_SERVICE_NAME" ]; then
  SERVER_LIST=`getent hosts tasks.$DB_SERVICE_NAME|awk '{print $1}'|tr '\n' ' '`
fi

# We break our IP list into array
IFS=', ' read -r -a backend_servers <<< "$SERVER_LIST"

config_file="/etc/maxscale.cnf"

# We start config file creation

cat <<EOF > $config_file
[maxscale]
threads=$THREADS

[Read Service]
type=service
router=readconnroute
router_options=synced
servers=$SERVER_LIST
connection_timeout=$CONNECTION_TIMEOUT
user=$USER
passwd=$PASS
enable_root_user=$ENABLE_ROOT_USER
max_connections=$READ_MAX_CONNECTIONS

[Read Listener]
type=listener
service=Read Service
protocol=MySQLClient
address=$HOSTNAME
port=$READ_PORT
#ssl=required
#ssl_cert=/etc/maxscale/ssl/server-cert.pem
#ssl_key=/etc/maxscale/ssl/server-key.pem
#ssl_ca_cert=/etc/maxscale/ssl/ca-server-cert.pem

[RW Splitter Service]
type=service
router=readwritesplit
servers=$SERVER_LIST
connection_timeout=$CONNECTION_TIMEOUT
user=$USER
passwd=$PASS
enable_root_user=$ENABLE_ROOT_USER
max_connections=$RW_MAX_CONNECTIONS

[RW Splitter Listener]
type=listener
service=RW Splitter Service
protocol=MySQLClient
address=$HOSTNAME
port=$RW_PORT
#ssl=required
#ssl_cert=/etc/maxscale/ssl/server-cert.pem
#ssl_key=/etc/maxscale/ssl/server-key.pem
#ssl_ca_cert=/etc/maxscale/ssl/ca-server-cert.pem

[Galera Monitor]
type=monitor
module=galeramon
servers=$SERVER_LIST
disable_master_failback=1
user=$USER
passwd=$PASS

[CLI]
type=service
router=cli

[CLI Listener]
type=listener
service=CLI
protocol=maxscaled
address=$HOSTNAME
port=$CLI_PORT

# Start the Server block
EOF

# add the [server] block
for i in ${!backend_servers[@]}; do
cat <<EOF >> $config_file
[${backend_servers[$i]}]
type=server
address=${backend_servers[$i]}
port=$BACKEND_PORT
protocol=MySQLBackend
EOF

done

exec "$@"