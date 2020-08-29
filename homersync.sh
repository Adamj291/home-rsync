#!/bin/bash
set -e

#SCRIPT VARIABLES
DATE=`date | awk {'print$1,$2,$6 " @ " $4'}` # DO NOT CHANGE
LOG=~/logs #PATH TO LOCAL LOG FILES
RLOG=/mnt/linuxdata/home/`users`/logs #PATH TO REMOTE LOG FILES
BACKPATH=/mnt/linuxdata/home/`users`/ #PATH TO REMOTE FOLDER LOCATION
ERROR=$LOG/homesync_error.txt #LOCATION OF ERROR LOG, IF EMPTY IT WILL BE DELETED AT END
SUCCESS=$LOG/homesync_lastsuccess.txt #PATH TO LAST SUCCESS LOG FILE, SUBSEQUENT SYNCS WILL OVERWRITE

#CHECK FOR LOG FILE LOCATIONS AND CREATE IF NOT EXISTING
[ -d $LOG ] || mkdir -p $LOG
[ -d $RLOG ] || mkdir -p $RLOG

# DISTROCHECK, IF NOT ARCH SCRIPT WILL EXIT
if [ `cat /etc/*release | grep DISTRIB_ID | sed 's/DISTRIB_ID=//g'` = "Arch" ];
then 
    echo -e "\033[1;32;50mYour are using Arch, you can proceed!\n\033[0m"
else 
    echo -e "\033[5;31;50mYour are not using Arch, this script will exit\033[0m" && sleep 5 && exit
fi

#COUNTDOWN FUNCTION FOR END OF SCRIPT MESSAGES
function countdown(){
   date1=$((`date +%s` + $1)); 
   while [ "$date1" -ge `date +%s` ]; do 
     echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
     sleep 0.1
   done
}

#FUNCTION TO EXPORT AUR PACKAGES TO LIST WITH DESCRIPTIONS AND ADD TO REPORT
function aur(){
    pacman -Qmq  1>> $LOG/aur.txt 2>> /dev/null
    yay -S --info - < $LOG/aur.txt > $LOG/aur2.txt # PROBLEM!!!
    sed -i 1d $LOG/aur2.txt
    cat $LOG/aur2.txt | grep -E 'Name|Description|Missing AUR Packages|Flagged Out Of Date AUR Packages' | sed 's/ -> //g' > $LOG/aur3.txt
    cat $LOG/aur3.txt 1>> $SUCCESS 2>> /dev/null
    rm $LOG/aur*
}

#FUNCTION TO EXPORT ARCH REPO PACKAGES TO LIST WITH DESCRIPTIONS AND ADD TO REPORT
function arch(){
    pacman -Qenq 1>> $LOG/archtmp.txt 2>> /dev/null
    pacman -Si - < $LOG/archtmp.txt > $LOG/archtmp2.txt
    cat $LOG/archtmp2.txt | grep -E 'Name|Description' > $LOG/archtmp3.txt
    cat $LOG/archtmp3.txt 1>> $SUCCESS 2>> /dev/null
    rm $LOG/archtmp*
}

# START OF BACKUP WITH DETAILS FOR REPORT
echo -e '\033[1;31;50mRUNNING BACKUP, PLEASE WAIT...\n\033[0m' & #SCRIPT MESSAGE
echo "---=== LAST SUCCESFUL BACKUPS REPORT ===---" 2>> $ERROR 1> $SUCCESS; # REPORT TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "Ran on $DATE" 2>> $ERROR 1>> $SUCCESS;
echo "Ran by "`whoami` 2>> $ERROR 1>> $SUCCESS;
echo "Kernel Version  "`uname -r` 2>> $ERROR 1>> $SUCCESS;
printf "\n" 2>> $ERROR 1>> $SUCCESS;
#FOLDER SYNC WITH DETAILS GOING TO REPORT
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "---=== HOME FOLDER BACKUP ===---" 2>> $ERROR 1>> $SUCCESS; # REPORT SECTION TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
# HOME FOLDER BACK UPS, ADD, DELET OR AMMEND AS NECCESARY
rsync -avr /home/`users`/Documents $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -avr /home/`users`/Downloads $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -avr /home/`users`/Pictures $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -arv /home/`users`/Videos $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -arv /home/`users`/scripts $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -arv /home/`users`/Music $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
#CONFIG SYNC WITH DETAILS GOING TO REPORT
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "---=== CONFIGURATION BACKUP ===---" 2>> $ERROR 1>> $SUCCESS; # REPORT SECTION TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "---=== ALIAS BACKUP ===---" 2>> $ERROR 1>> $SUCCESS; # REPORT SECTION TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
grep alias ~/.bashrc 2>> $ERROR 1>> $SUCCESS;
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "---=== FSTAB CONFIGURATION ===---" 2>> $ERROR 1>> $SUCCESS; # REPORT SECTION TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
cat /etc/fstab 2>> $ERROR 1>> $SUCCESS;
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "---=== CRONTAB CONFIGURATION ===---" 2>> $ERROR 1>> $SUCCESS; # REPORT SECTION TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
crontab -l 2>> $ERROR 1>> $SUCCESS;
printf "\n" 2>> $ERROR 1>> $SUCCESS;
echo "---=== BASHRC/CRENEDTIALS/CONKY BACKUP ===---" 2>> $ERROR 1>> $SUCCESS; # REPORT SECTION TITLE
printf "\n" 2>> $ERROR 1>> $SUCCESS;
cat /home/`users`/.bashrc 2>> $ERROR 1>> $SUCCESS;
printf "\n" 2>> $ERROR 1>> $SUCCESS;
printf " ----- END OF BASH RC FILE ----- " 2>> $ERROR 1>> $SUCCESS;
printf "\n\n" 2>> $ERROR 1>> $SUCCESS;
rsync -arv /home/`users`/.bashrc $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -arv /home/`users`/.credentials $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS; 
rsync -arv /home/`users`/.conky $BACKPATH --delete --inplace --no-links 2>> $ERROR 1>> $SUCCESS;
#CHECKS FOR ERROR FILE, IF ZERO BYTES DELETE
find $ERROR -type f -empty -delete;
#find $RLOG/homesync_error.txt -type f -empty -delete;

#CHECKS FOR ERROR FILE, IF EXISTS THE DISPLAY ERROR, IF NOT RUN THE PACKAGE LIST FUNCTIONS AND ADD TO REPORT
#ADDS TIME TO REPORT AND DISPLAYS SUCCESS MESSAGE FOR 5 SECONDS
if [ -f $ERROR ];
then
    echo -e "\033[5;31;50mAn error has occoured, please check $ERROR \033[0m"; 2>> /dev/null; sleep 5 & countdown 5
else
    printf "\n" 1>> $SUCCESS 2>> /dev/null;
    echo "---=== AUR PACKAGES INSTALLED LOCALLY" 1>> $SUCCESS 2>> /dev/null; # REPORT SECTION TITLE
    printf "\n" 1>> $SUCCESS 2>> /dev/null;
    aur &&
    printf "\n" 1>> $SUCCESS 2>> /dev/null;
    echo "---=== OFFICIAL REPOSITORY PACKAGES INSTALLED LOCALLY" 1>> $SUCCESS 2>> /dev/null; # REPORT SECTION TITLE
    printf "\n" 1>> $SUCCESS 2>> /dev/null;
    arch &&
    printf "\n" 1>> $SUCCESS 2>> /dev/null;
    echo -e "\nBackup has completed Succesfully on $DATE"  >>  $SUCCESS;
    rsync -arv $LOG/ $RLOG/ --delete --inplace --no-links &>> /dev/null;
    echo -e "\033[1;32;50mBackup has completed Succesfully\nPlease see $SUCCESS for details\n\033[0m"; sleep 5 & countdown 5
fi
