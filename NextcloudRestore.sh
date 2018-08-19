#!/bin/bash

#
# Bash script for restoring backups of Nextcloud.
# Usage: ./NextcloudRestore.sh <NameOfBackup> (for example ./NextcloudRestore.sh 20180819_153907)
# 
# This script is based on a Nextcloud installation using Apache2 and MariaDB (https://techwombat.com/install-nextcloud-12-server-debian-9-https) which I adopted for my needs.
#
# IMPORTANT!!!
# You have to customize this script (directories, users, passwords etc.) for your actual environment, otherwise strange things (or none at all) will happen!
# All entries which need to be customized are tagged with "CHANGEME".
#

# Variables
# CHANGEME: The external (!) directory where your Nextcloud-backups are stored
mainBackupDir="/mnt/backup/Nextcloud/"
restore=$1
currentRestoreDir="${mainBackupDir}/${restore}"
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

# File names for backup files
# If you prefer other file names, you'll also have to change the NextcloudBackup.sh script.
fileNameBackupFileDir="nextcloud-files.tar.gz"
fileNameBackupDataDir="nextcloud-data.tar.gz"
fileNameBackupDb="nextcloud-db.sql"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check if parameter given
#
if [ $# != "1" ]
then
    errorecho "ERROR: No backup name for restore given!"
	errorecho "Usage: NextcloudRestore.sh 'BackupDate'"
    exit 1
fi

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
    errorecho "ERROR: This script has to be run as root!"
    exit 1
fi

#
# Check if backup dir exists
#
if [ ! -d "${currentRestoreDir}" ]
then
	 errorecho "ERROR: Backup ${restore} not found!"
    exit 1
fi

#
# Set maintenance mode
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
# Delete old Nextcloud-directories
#
echo "Deleting old Nextcloud file-directory..."
rm -r "${nextcloudFileDir}"
mkdir -p "${nextcloudFileDir}"
echo "Done"
echo

echo "Deleting old Nextcloud data-directory..."
rm -r "${nextcloudDataDir}"
mkdir -p "${nextcloudDataDir}"
echo "Done"
echo

#
# Restore file- and data-directory
#
echo "Restoring Nextcloud file-directory..."
tar -xpzf "${currentRestoreDir}/${fileNameBackupFileDir}" -C "${nextcloudFileDir}"
echo "Done"
echo

echo "Restoring Nextcloud data-directory..."
tar -xpzf "${currentRestoreDir}/${fileNameBackupDataDir}" -C "${nextcloudDataDir}"
echo "Done"
echo

#
# Restore database
#
echo "Dropping old Nextcloud-database, forcing it to bite the dust..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "DROP DATABASE ${nextcloudDatabase}"
echo "Done"
echo

echo "Creating new database for Nextcloud straight out of the digital womb..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "CREATE DATABASE ${nextcloudDatabase}"
echo "Done"
echo

echo "Restoring backup-database and putting life in the empty one..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" "${nextcloudDatabase}" < "${currentRestoreDir}/${fileNameBackupDb}"
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
# Set directory permissions
#
echo "Setting final directory permissions..."
chown -R "${webserverUser}":"${webserverUser}" "${nextcloudFileDir}"
chown -R "${webserverUser}":"${webserverUser}" "${nextcloudDataDir}"
echo "Done"
echo

#
# Update the system data-fingerprint (see https://docs.nextcloud.com/server/13/admin_manual/configuration_server/occ_command.html#maintenance-commands-label)
#
echo "Updating the system data-fingerprint..."
cd "${nextcloudFileDir}"
sudo -u "${webserverUser}" php occ maintenance:data-fingerprint
cd ~
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

echo
echo "DONE - Go ahead, make your (Nextcloud-) day!"
echo "Backup ${restore} successfully restored."
