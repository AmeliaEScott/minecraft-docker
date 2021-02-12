#!/bin/bash
# These first 3 files set up a user with the same PUID and PGID as the user on the host machine.
# This is so that all of the files created have the right permissions and ownership.
groupadd --force --gid $PGID minecraft
useradd -c 'container user' -u $PUID -g $PGID minecraft
chown -R $PUID:$PGID /scripts
chown -R $PUID:$PGID /server
chown -R $PUID:$PGID /backup

# TODO: Timezone?

# Intercept the shutdown signal to send a nice, friendly "stop" command to the server
cleanup() {
    echo "Container stopped, stopping server cleanly..."
    rconclt ${RCON_PASSWORD}@localhost:${RCON_PORT} stop
}
trap 'cleanup' SIGTERM

# All commands from now on should be run as the minecraft user.
sudo -HE -u minecraft python3.8 /scripts/update_server.py

# Actually run the Minecraft server (as the minecraft user)
cd /server
sudo -HE -u minecraft bash -c /server/runserver.sh &

# Setup auto backups
# Need to pass in the RCON_PASSWORD and RCON_PORT environment variables to the backup script.
# But cron doesn't know these environment variables normally. So I just embed their values
# directly in the crontab file. It's a dirty hack, but it works.
printf "${BACKUP_SCHEDULE} RCON_PASSWORD=${RCON_PASSWORD} RCON_PORT=${RCON_PORT} sudo -HE -u minecraft /scripts/backup.sh \n\n" | crontab -
cron -f &

wait $!