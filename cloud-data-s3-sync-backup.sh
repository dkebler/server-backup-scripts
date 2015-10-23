#!/bin/sh

#set -x

BACKUPDIR="/root/.backups"
DATA="/mnt/data/oc-data"
THESITE="owncloud-healthwrights"
THEBUCKET="cloud-backup.healthwrights.org"
THEDATE=`date +%a-%b-%d-%Y--%H:%M`
STALE="15"
EMAILTO="healthwrights@gmail.com"
EMAILFROM="admin-noreply<admin@healthwrights.org>"
EMAILSUBJECT="Cloud System Backed Up to S3 via Cron Job"
EMAILBODY="AWS Healthwrights Cloud Sync to S3 cloud-backup.healthwrights.org on "

# echo  "Sync Cloud Files to cloud-backup.kebler.net on S3 at `date`" >> /root/testcron

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-
# Open STDOUT as $LOG_FILE file for read and write.
mkdir -p $BACKUPDIR/$THESITE/logs
exec 1<>"$BACKUPDIR/$THESITE/logs/log-sync_${THESITE}_${THEDATE}.log"
# Redirect STDERR to STDOUT
exec 2>&1

echo "$EMAILBODY $THEDATE"
echo ----------------------
echo "Removing backups and logs older than $STALE days"
find $BACKUPDIR/$THESITE/system/sys* -mtime +$STALE -exec rm {} \;
find $BACKUPDIR/$THESITE/database/db* -mtime +$STALE -exec rm {} \;
find $BACKUPDIR/$THESITE/logs/log* -mtime +$STALE -exec rm {} \;
echo "Current Backups"
ls -l -R "$BACKUPDIR/$THESITE"
echo -------------------
echo "syncing db dump, system files and backup logs to S3 Bucket $THEBUCKET"
/usr/local/bin/aws s3 sync $BACKUPDIR/$THESITE s3://$THEBUCKET --quiet --only-show-errors --delete
echo "db,sys,log files synced, syncing owncloud data"
/usr/local/bin/aws s3 sync $DATA s3://$THEBUCKET/data --quiet --only-show-errors --delete --exclude "cache/" 
echo "data synced to s3, sending email"
# echo "$EMAILBODY $THEDATE" | mailx -s "$EMAILSUBJECT" $EMAILTO
echo "$EMAILBODY $THEDATE"  | mailx -s "$EMAILSUBJECT" -a "$BACKUPDIR/$THESITE/logs/log-sync_${THESITE}_${THEDATE}.log" $EMAILTO
