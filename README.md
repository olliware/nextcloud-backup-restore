# Nextcloud-Backup-Restore

This repository contains two bash scripts for backup/restore of Nextcloud(https://nextcloud.com/).

It is based on a Nextcloud installation using Apache2 and MariaDB (see the tutorial [How to Install Nextcloud 12 Server on Debian 9 with HTTPS](https://techwombat.com/install-nextcloud-12-server-debian-9-https) which I adopted for my needs. The German version I have planned so far could be released sometimes on Ollis Blog (https://ollis.blog) but I haven't had the time for that... yet!

## General information

For a complete backup of any Nextcloud-instance, you should backup three items:

- The Nextcloud file directory (usually */var/www/nextcloud*)
- The data directory of Nextcloud (it's recommended to locate this not under the web root, so e.g. */var/nextcloud_data*)
- The Nextcloud database

The scripts take care of these three items to backup automatically.

**Important:**

- After cloning or downloading the repository, you'll have to edit the scripts so that they represent your current Nextcloud installation (directories, users, etc.). All values which need to be customized are marked with *TODO* in the script's comments.
- The scripts assume that Nextcloud's data directory is *not* a subdirectory of the Nextcloud installation (file directory). The general recommendation is that the data directory should not be located somewhere in the web folder of your webserver (usually */var/www/*), but in a different folder (e.g. */var/nextcloud_data*). For more information, see [here](https://docs.nextcloud.com/server/13/admin_manual/installation/installation_wizard.html#data-directory-location-label).
- However, if your data directory *is* located under the Nextcloud file directory, you'll have to change the scripts so that the data directory is not part of the backup/restore (otherwise, it would be copied twice).
- The scripts only backup the Nextcloud data directory. If you have any external storage mounted in Nextcloud, these directories have to be handled separately.
- If you have enabled 4 byte support (see [Nextcloud Administration Manual](https://docs.nextcloud.com/server/13/admin_manual/configuration_database/mysql_4byte_support.html)) while backup, you have to enable 4 byte support on the target system *before* restoring the backup.
- If you do not want to save the database password in the scripts, remove the variable *dbPassword* and call *mysql* with the *-p* parameter (without password). When calling the scripts manually, you'll be asked for the database password. 

## Backup

In order to create a backup, simply call the script *NextcloudBackup.sh* on your Nextcloud machine.
This will create a directory with the current time stamp in your main backup directory (you already edited the script so that it fits your Nextcloud installation, haven't you): As an example, this would be */mnt/Share/NextcloudBackups/20170910_132703*.

## Restore

For restore, just call *NextcloudRestore.sh*. This script expects one parameter which is the name of the backup to be restored. In our example, this would be *20170910_132703* (the time stamp of the backup created before). The full command for a restore would be *./NextcloudRestore.sh 20170910_132703*.
