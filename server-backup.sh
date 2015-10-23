#!/bin/sh

SCRIPTDIR="/root/backup-scripts"
CONFNAME="server-backup.conf"
THEBUCKET="backup.healthwrights.org"

#uncomment for debugging and testing
# set -x

# add -n for dry run
dupbu -c $SCRIPTDIR/$CONFNAME -b 
dupbu -c $SCRIPTDIR/$CONFNAME -s
# backup these scripts daily in case of changes
/usr/local/bin/aws s3 sync $SCRIPTDIR s3://$THEBUCKET/backup-scripts --quiet --only-show-errors --delete   
