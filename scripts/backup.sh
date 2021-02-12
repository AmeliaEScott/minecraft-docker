#!/bin/bash
# This script is called automatically by Cron, based on the ${BACKUP_SCHEDULE} environment variable.

rconclt ${RCON_PASSWORD}@localhost:${RCON_PORT} say Backing up server...
rconclt ${RCON_PASSWORD}@localhost:${RCON_PORT} save-all

rdiff-backup /server /backup