#!/bin/bash
# These first 3 files set up a user with the same PUID and PGID as the user on the host machine.
# This is so that all of the files created have the right permissions and ownership.
groupadd --force --gid $PGID minecraft
useradd -c 'container user' -u $PUID -g $PGID minecraft
chown -R $PUID:$PGID /scripts
chown -R $PUID:$PGID /server
chown -R $PUID:$PGID /backup

# TODO: Timezone

# Intercept the shutdown signal to send a nice, friendly "stop" command to the server
cleanup() {
    echo "Container stopped, stopping server cleanly..."
    rconclt ${RCON_PASSWORD}@localhost:${RCON_PORT} stop
}
trap 'cleanup' SIGTERM

# All commands from now on should be run as the minecraft user.
sudo -HE -u minecraft python3.8 /scripts/update-server.py

# TODO: Setup auto backups

cd /server
sudo -HE -u minecraft bash -c /server/runserver.sh &

wait $!