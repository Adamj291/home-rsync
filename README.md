# **Arch Linux Home rsync Script**

This script is designed for me to backup my essential home folders and configuration files onto my NAS unit, it assumes that the destination is already setup and added to the fstab file.

I designed this script to vreate a report for the config and results and also an error file if the script fails.

## **What is backed up**

This script backs up the following

**Files**

- Home folders
	 - Documents
	 - Downloads
	 - Pictures
	 - Videos
	 - Music
	 - scripts (My own folder I created under /~)  

- bashrc file
- conky files from ~/.conky
- crednetial file used for fstab mounting
	 
**Configuration - Sent to a report txt file under ~/logs and at destination**

- Alias configuration from .bashrc
- fstab configuration from /etc/fstab
- crontab configuration
- complete .bashrc file contents
- crednetial details
- List of all installed packages from Arch repository
- List of all installed packages from Arch User repository

## **Variables to change**

The main script variables are at the start of the script and are as follows:

**The local log file path**  
`LOG=~/logs`  
**The Remote log file path**  
`RLOG=/mnt/linuxdata/home/`users`/logs`  
**The Destination path for backed up files**  
`BACKPATH=/mnt/linuxdata/home/`users`/`  
**Name and patch of error file**  
`ERROR=$LOG/homesync_error.txt`  
**Name and patch of report file**  
`SUCCESS=$LOG/homesync_lastsuccess.txt`

## **Other Changes**

Lines 65 to 70 are the files being backed up, the can be added to, removed or amended to suite and will reflect on the report file.