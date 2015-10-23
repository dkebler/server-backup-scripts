#!/bin/sh

#set -x

SCRIPTDIR="/root/backup-scripts"
THEDATE=`date +%a-%b-%d-%Y--%H:%M`
VOL="vol-df1b342a"
REGION="us-west-2"
PURGEALLOW="1"
PURGE="2"
EMAILTO="healthwrights@gmail.com"
EMAILFROM="admin-noreply<admin@healthwrights.org>"
EMAILSUBJECT="Healthwrights Server Root Snapshot Taken"
EMAILBODY="AWS Healthwrights Server Snap taken of EBS Root Volume $VOL on $THEDATE"
NAMETAG="$THEDATE Snap of Root $VOL"
LOG_FILE="$SCRIPTDIR/snap-logs/log-snap_${THEDATE}.log"

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-
# Open STDOUT as $LOG_FILE file for read and write.
mkdir -p $SCRIPTDIR/snap-logs
exec 1<>$LOG_FILE
# Redirect STDERR to STDOUT
exec 2>&1

echo "$NAMETAG"
echo "$EMAILBODY $THEDATE"
echo "-------------"
echo "current backup snapshots"

aws ec2 describe-snapshots --filter Name=tag:PurgeAllow,Values=true

ec2snap -n -u -r "$REGION" -v "$VOL" -k $PURGEALLOW -p $PURGE 

echo "-------------"
echo "snapshots after adding and purging"

aws ec2 describe-snapshots --filter Name=tag:PurgeAllow,Values=true

echo ----------------------
echo "Removing logs older than $PURGE days"
find $SCRIPTDIR/snap-logs/log* -mtime +$PURGE -exec rm {} \;
echo "Logs of Availabe Snaps"
ls -l $SCRIPTDIR/snap-logs
echo "-------------------"
cat $LOG_FILE  | mailx -s "$THEDATE -- $EMAILSUBJECT" $EMAILTO
