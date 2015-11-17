#!/bin/sh

# set -x

# Password is in .my.cnf file in /root
 
TIMESTAMP=`date +%Y-%m-%d:%b-%a@%H-hrs`
BACKUP_ROOT=/root/.backups
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
MYSQL_USER="readonly"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
THEBUCKET="backup.healthwrights.org"
LOG_FILE="$BACKUP_DIR/backup-n-sync_${TIMESTAMP}.log"
STALE="2"
EMAILTO="healthwrights@gmail.com"
EMAILFROM="admin-noreply<admin@healthwrights.org>"
EMAILSUBJECT="$TIMESTAMP - Databases and Webs Backed Up and Copied to S3"
EMAILBODY="AWS Healthwrights Database Dumps and Web Files back up and send to S3 backup.healthwrights.org"

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-
# Open STDOUT as $LOG_FILE file for read and write.
mkdir -p $BACKUP_DIR/log
exec 1<>$LOG_FILE
# Redirect STDERR to STDOUT
exec 2>&1

echo "$EMAILBODY on $TIMESTAMP"

# Make Backup of Databases 
mkdir -p "$BACKUP_DIR/databases"
 
databases=`$MYSQL --user=$MYSQL_USER -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`
 
for db in $databases; do
echo "Dumping Database: $db"	
$MYSQLDUMP --force --opt --user=$MYSQL_USER --databases $db | gzip > "$BACKUP_DIR/databases/${db}_${TIMESTAMP}.sql.gz"
done

EXCLUDE_DIR="healthwrights.org/content/*"

#Make Backup of Web Directories
mkdir -p "$BACKUP_DIR/webs"

cd /var/www
for dir in */
do
  base=$(basename "$dir")
echo "Archiving var/www/$dir with permissions"
tar czpf "$BACKUP_DIR/webs/var-www_${base}_${TIMESTAMP}.tgz" --exclude=/var/www/$EXCLUDE_DIR -C / "/var/www/$dir"
done

echo "Archive etc/apache2 Apache Server Config"
tar czpf "$BACKUP_DIR/webs/etc-apache2_${TIMESTAMP}.tgz" -C / "/etc/apache2"

# sync backup to S3

echo ----------------------
echo "Backups Before Purge"
ls -l "$BACKUP_ROOT"
echo -------------------
echo "Removing backups and logs older than $STALE days"
find $BACKUP_ROOT/* -iname "[0-9]*" -mtime +$STALE -exec rm -r "{}" \;
echo "Backups After Purge"
ls -l "$BACKUP_ROOT"
echo -------------------
echo "syncing db dump, system files and backup logs to S3 Bucket $THEBUCKET not using --delete"
#using bucket lifecycle to remove older backups on S3, removed --delete from command below 
/usr/local/bin/aws s3 sync $BACKUP_ROOT s3://$THEBUCKET/db-webs --quiet --only-show-errors 
echo "webs synced to s3, sending email"
cat $LOG_FILE  | mailx -s "$EMAILSUBJECT" $EMAILTO