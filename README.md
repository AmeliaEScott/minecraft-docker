# Minecraft Docker

This container is the basic bare minimum needed to run a minecraft server in a Docker container. It also does
regular backups using rdiff-backup.

To run using docker-compose:

```
version: "2.1"
services:
  minecraft:
    image: minecraft-docker:latest
    container_name: minecraft
    environment:
      - PUID=1000  # Set to the same as the host user to keep file permissions sane
      - PGID=1000
      - TZ=Europe/New_York  # Currently unused. TODO: Implement
      - MC_VERSION=latest_release  # See below for options
      - RCON_PASSWORD=password  # Should match `rcon.password` in server.properties
      - RCON_PORT=25575  # Optional, defaults to 25575. Should match `rcon.port` in server.properties
      - BACKUP_SCHEDULE=*/2 * * * * *  # Use cron syntax here. Currently unimplemented. TODO
    volumes:
      - /path/to/server/folder:/server
      - /path/to/backup/folder:/backup
    ports:
      - 25565:25565  # Make sure the container port (the one after the colon) matches 'server-port' in server.properties
      - 25575:25575  # Optional, to expose the server RCON outside of the container
    restart: unless-stopped
```

## Minecraft Server Configuration

This container is designed to be fairly flexible, in terms of custom or modified servers. However, there are a few
specific settings which must be enabled for the scripts to work correctly:

- In `server.properties`:
    - `enable-rcon=true`: Enable the RCON connection, so that the scripts in this container can
      interact with the server (For example, to send the `stop` command when the container stops)
    - `rcon.password` should be the same as the container environment variable `RCON_PASSWORD`
    - `rcon.port` should be the same as the container environment variable `RCON_PORT`
    - `server-port` should be exposed in the container's `ports` settings.
    

## `PUID` and `PGID`

Minecraft servers create a lot of files. By default, docker containers run everything as the root user, with UID 0.
Because you'll probably use this container by bind-mounting your server folder from your host, this
could result in a world folder that's difficult to work with because it is owned by the root user.

To fix this, just pass in the `PUID` and `PGID` environment variables to be equal to the `$UID` and `$GID` of your 
host user. The container will run the Minecraft server under a user with the same UID and GID, so the resulting
files will all be owned by your user on the host.

TL;DR: If you only have 1 user account on your computer, probably just leave `PUID` and `PGID` as 1000, like in the
example above.

## Automatic Updates

This container can be configured to automatically update the Minecraft server on startup. To control this,
use the `MC_VERSION` environment variable when you create the container:

- `MC_VERSION=latest_release`: Download the latest release version
- `MC_VERSION=latest_snapshot`: Download the latest snapshot/prerelease version
- `MC_VERSION=1.16.1`: Download the exact given version
- `MC_VERSION` is unset: Skip automatic updates completely. You'll have to provide a server jar.

If `MC_VERSION` is set, then the server is downloaded immediately on container launch. Any errors
will be printed to the container's console. The server will be saved to `/server/server.jar` within
the container (which has, presumably, been linked to a directory on the host). If this file
already exists, and is already the correct version, then no download is done.

You can use a custom/modified server jar. There are two ways to do this:

- Disable server auto-updates by leaving `MC_VERSION` unset, and put your custom jar at `/server/server.jar`.
- Name your custom server something other than `server.jar`, and create a custom `runserver.sh` (see below).
    - You should also disable server auto-updates, but if you don't, the only downside is that the server
      is unnecessarily downloaded and not used.

## `runserver.sh` and custom Java arguments

The entrypoint of this container expects the file `/server/runserver.sh` to be used the launch the server.
The auto-update script will check whether this file exists. If not, it will copy over the default one located
in the `scripts` folder.

Your `runserver.sh` can do whatever you want: Set java parameters (like memory), run an extra backup
on server startup/shutdown, or whatever else. But all it really __needs__ to do is launch your server. 

The `entrypoint.sh` will launch your `runserver.sh` script as the `minecraft` user, not as root.

## Automatic Backups

TODO: Implement and document this feature