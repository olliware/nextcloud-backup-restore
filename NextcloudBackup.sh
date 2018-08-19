#!/bin/bash

#
# Bash script for creating backups of Nextcloud.
# Usage: ./NextcloudBackup.sh
# 
# This script is based on a Nextcloud installation using Apache2 and MariaDB (https://techwombat.com/install-nextcloud-12-server-debian-9-https) which I adopted for my needs.
#

# IMPORTANT!!!
# You have to customize this script (directories, users, passwords etc.) for your actual environment, otherwise strange things (or none at all) will happen!
# All entries which need to be customized are tagged with "CHANGEME".
#

# Variables
currentDate=$(date +"%Y%m%d_%H%M%S")
# CHANGEME: The external (!) directory where you want to store your Nextcloud-backups
backupMainDir="/mnt/backup/Nextcloud"
# The actual directory of the current backup - this is a subdirectory of the main directory above with a decent timestamp
backupdir="${backupMainDir}/${currentDate}/"
# CHANGEME: The base-directory of your Nextcloud-installation (should be a "/nextcloud"-directory just under your webroot)
nextcloudFileDir="/var/www/nextcloud"
# CHANGEME: The directory of your Nextcloud-data directory (outside the Nextcloud file directory - default installations put this into "/data" among "/nextcloud")
# If your data directory is located under Nextcloud's file directory, the data directory should not be a separate part of the backup!
nextcloudDataDir="/var/nextcloud_data"
# CHANGEME: The service name of the webserver you use. Used to start/stop web server (e.g. 'systemctl stop <webserverServiceName>')
webserverServiceName="apache2"
# CHANGEME: Your Nextcloud database name
nextcloudDatabase="nextcloud"
# CHANGEME: Your Nextcloud database user
dbUser="nextcloud"
# CHANGEME: The password of the Nextcloud database-user
dbPassword="Pa$$w0RD"
# CHANGEME: Your webserver user (usually "www-data")
webserverUser="www-data"
# CHANGEME: The maximum number of backups to keep (when set to 0, all backups are kept which may cause some problems with disk space once)
maxNrOfBackups=0

# File names for backup files
# If you prefer other file names, you'll also have to change the NextcloudRestore.sh script.
fileNameBackupFileDir="nextcloud-files.tar.gz"
fileNameBackupDataDir="nextcloud-data.tar.gz"
fileNameBackupDb="nextcloud-db.sql"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
	errorecho "ERROR: This script has to be run as root!"
	exit 1
fi

#
# Check if backup directory already exists
#
if [ ! -d "${backupdir}" ]
then
	mkdir -p "${backupdir}"
else
	errorecho "ERROR: The backup directory ${backupdir} already exists!"
	exit 1
fi

#
# Set maintenance mode active
#
echo "Set maintenance mode for Nextcloud..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:mode --on
cd ~
echo "Done"
echo

#
# Stop the webserver
#
echo "Stopping webserver..."
service "${webserverServiceName}" stop
echo "Done"
echo

#
# Backup file and data directory
#
echo "Creating backup of Nextcloud file-directory..."
tar -cpzf "${backupdir}/${fileNameBackupFileDir}" -C "${nextcloudFileDir}" .
echo "Done"
echo

echo "Creating backup of Nextcloud data-directory..."
tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${nextcloudDataDir}" .
echo "Done"
echo

#
# Backup Database
#
echo "Backup Nextcloud-database..."
mysqldump --single-transaction -h localhost -u "${dbUser}" -p"${dbPassword}" "${nextcloudDatabase}" > "${backupdir}/${fileNameBackupDb}"
echo "Done"
echo

#
# Start the webserver
#
echo "Starting webserver..."
service "${webserverServiceName}" start
echo "Done"
echo

#
# Disable maintenance mode
#
echo "Switching off maintenance mode..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:mode --off
cd ~
echo "Done"
echo

#
# Delete old backups - if set in "maxNrOfBackups" > 0
#
if (( ${maxNrOfBackups} != 0 ))
then	
	nrOfBackups=$(ls -l ${backupMainDir} | grep -c ^d)
	
	if (( ${nrOfBackups} > ${maxNrOfBackups} ))
	then
		echo "Removing previous backups..."
		ls -t ${backupMainDir} | tail -$(( nrOfBackups - maxNrOfBackups )) | while read dirToRemove; do
		echo "${dirToRemove}"
		rm -r ${backupMainDir}/${dirToRemove}
		echo "Done"
		echo
    done
	fi
fi

echo
echo "JOB DONE!"
echo "Backup created: ${backupdir}"
