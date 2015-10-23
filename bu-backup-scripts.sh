#!/bin/sh

SCRIPTDIR="/root/backup-scripts"
THEBUCKET="backup.healthwrights.org"

#uncomment for debugging and testing
# set -x

/usr/local/bin/aws s3 sync $SCRIPTDIR s3://$THEBUCKET/backup-scripts --quiet --only-show-errors --delete   