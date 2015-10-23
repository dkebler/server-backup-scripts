#!/bin/sh
# This was orginal script to do owncloud backup but now using duplicity so just need the part for dumping the database.  The code and data will be backed up via duplicity itself.
BACKUPDIR="/root/.backups"
THESITE="owncloud"
THEDB="owncloud"
THEDBUSER="owncloud"
THEDBPW="pMR6sDecaD2582dw"
THEDATE=`date +%m-%d-%y--%H-%M`
THEBUCKET="cloud-data.kebler.net"
STALE="30"


if [[ ! -e $BACKUPDIR/$THESITE/ ]]; then
    mkdir $BACKUPDIR/$THESITE/
fi


echo "Dumping Database $THEDB to $BACKUPDIR/$THESITE/"
mysqldump -u $THEDBUSER -p${THEDBPW} $THEDB | gzip > $BACKUPDIR/$THESITE/dbbackup_${THEDB}_${THEDATE}.sql.gz
echo "Dump Completed, Archiving Site $THESITE"
tar czf $BACKUPDIR/$THESITE/sitebackup_${THESITE}_${THEDATE}.tar -C / var/www/$THESITE
echo "Archive complete, removing backups older than $STALE days"
find $BACKUPDIR/$THESITE/site* -mtime +30 -exec rm {} \;
find $BACKUPDIR/$THESITE/db* -mtime +30 -exec rm {} \;
echo "backups removed, sync backups to S3 Bucket $THEBUCKET"
/usr/local/bin/aws s3 sync $BACKUPDIR/$THESITE s3://$THEBUCKET/$THESITE --delete
echo "Transfer complete, backup job finished"
