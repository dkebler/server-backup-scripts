#!/bin/sh

SCRIPTDIR="/root/backup-scripts"
CONFNAME="server-backup.conf"
THEBUCKET="backup.healthwrights.org"

dupbu -c $SCRIPTDIR/$CONFNAME -l > /root/backup-scripts/logs/server-files.txt

/usr/local/bin/aws s3 sync $SCRIPTDIR s3://$THEBUCKET/backup-scripts --quiet --only-show-errors --delete   
