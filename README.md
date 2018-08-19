# Nextcloud-Backup-Restore

This repository contains two bash scripts for Backup and Restore of Nextcloud (https://nextcloud.com/).

It is based on a Nextcloud installation using Apache2 and MariaDB (see the tutorial [How to Install Nextcloud 12 Server on Debian 9 with HTTPS](https://techwombat.com/install-nextcloud-12-server-debian-9-https) which I adopted for my needs. The German version I have planned so far could be released sometimes on Ollis Blog (https://ollis.blog) but I haven't had the time for that... yet!

So far, feel free to search all other Nextcloud-related articles on my blog at https://ollis.blog/?s=nextcloud!

## General information

For a complete backup of any Nextcloud-instance, you should backup three items:

- The Nextcloud file directory (usually, for example located in /var/www/nextcloud)
- The data directory of Nextcloud (it is recommended to keep this away from the web root, e.g. /var/nextcloud_data)
- The Nextcloud database

The scripts take care of these three items to do an automatically backup to a specific mounted volume, of course this should not be located on the volume you want to backup!

**Important:**

- After cloning or downloading the repository, you'll have to edit the scripts so that they represent your current Nextcloud installation as it coms to directories, users, and so on. All values which need to be customized are marked with *CHANGEME* in the script's comments snd should be edited to make everything working
- The scripts assume that Nextcloud's data directory is *not* a subdirectory of the Nextcloud installation of, for example, /var/www/nextcloud. The general recommendation is that the data directory should not be located somewhere in the web folder of your webserver (usually /var/www) but in a different folder (here: /var/nextcloud_data) instead. For more information, see https://docs.nextcloud.com/server/13/admin_manual/installation/installation_wizard.html#data-directory-location-label.
- However, if your data directory IS located under the Nextcloud file-directory, you'll have to change the scripts so that the data directory is not part of the backup/restore (otherwise, it would be copied twice and that really makes no sense at all).
- The scripts only backup the Nextcloud data directory. If you have any external storage mounted in Nextcloud, these directories have to be handled separately but as we want to keep our data in our hands, we don't need external storage backups here
- If you have enabled 4 byte-support (see [Nextcloud Administration Manual](https://docs.nextcloud.com/server/13/admin_manual/configuration_database/mysql_4byte_support.html)) while backup, you have to enable 4 byte support on the target system just before (!) restoring the backup!
- If you do not want to save the database password in the scripts, remove the variable "dbPassword" and call "mysql" with the "-p"-parameter which simply means "without password". When calling the scripts manually, you will be asked for the database password so that a backup is possible after all!

## Backup

In order to create a backup, simply call the script "NextcloudBackup.sh" on your Nextcloud-server. This will create a directory with the current time stamp in your main backup directory (assuming you already edited the script so that it fits your Nextcloud-installation, haven't you?). For example, this would be "/mnt/Share/NextcloudBackups/20180819_153907". And yes - just to mention it again - the share should reside elsewhere OUTSIDE of your productive environment!

## Restore

For restore, just call "NextcloudRestore.sh" in the folder the script resides. It expects one parameter which is the name of the backup to be restored. In our example, this would be "20180819_153907" (the timestamp of the backup you have just created before). The full command for a restore would be "./NextcloudRestore.sh 20180819_153907" - there you go!
