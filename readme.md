# Server-Backup-Scripts with AWS S3 and EC2 Snapshot

This is a set of three scripts with a cron job to back up an ubuntu server (in particular an AWS-EC2 instance).  It makes use of S3.

1.  Script to dump all the mysql databases and wrap up all the directories in var/www as well as apache settings in etc/apache.  Puts them all in a single directory and then sends a copy to an s3 bucket which you can set up appropriate life cycle settings on.

2.  Uses duplicity backup to do incremental backups of the entire filesystem.  These are saved directly to an s3 bucket.

3.  Takes an AWS EC2 snaphot based on cron job but allows you to specify when old snaphots will be purged.

The scripts are best loaded to a /root/backup-scripts directory on your server

There is an install script makes links to the library scripts and the cron job where they need to be in order to execute.

The prerequisites are 


1. http://duplicity.nongnu.org/uplicity  (try the ppa install)

2. AWS-CLI 
 
on the server where you will put these scripts.


TODO:

Improve this documentation! (11/17/15)

Have the snapshots keep also a weekly and a monthly

-------------
 
On the backs of giants these scripts depend on these two repos of which a local (modified) copy is found in the /bin directory.

https://github.com/zertrin/duplicity-backup

https://github.com/colinbjohnson/aws-missing-tools/tree/master/ec2-automate-backup