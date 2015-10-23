#!/bin/sh

SCRIPTDIR="/root/backup-scripts"
CONFNAME="server-backup.conf"

#uncomment for debugging and testing
# set -x

dupbu -c $SCRIPTDIR/$CONFNAME -s

  
