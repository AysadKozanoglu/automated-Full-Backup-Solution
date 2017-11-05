#!/bin/bash
#+--------------------------------------------------------------------------------------+
#  Author: Aysad Kozanoglu
#  email : aysadx@gmail.com
# Version: 1.0
#
#   (Türkiye / Germany)
#
# =============================
# Full automated Backup script
# daily weekly monthly backups 
# with backupSet Credentials
# =============================
#
# crontab credendials 
# (hold the steps below first monthly than Weekly and at last Daily)
#
# 0  23 28-31 * * [ $(date -d +1day +%d) -eq 1 ] && backup.sh monthly 	
# 20 23 * * 7 backup.sh weekly (sunday)
# 30 23 * * * backup.sh daily
#
#
#--------------------------
# Monthly backup will do:
# -------------------------
# will run onyly between 28-31 days of Month and
# if the next day is the 1. day of next month, Monthly backup will run
#  ->> see crontab example before^
#
# if monthly backup run success with the cron credentials 
# (cron will execute  only between 28-31 of the monthday)
#   ->>then weekly backup will get symlink from current success running monthly backup
#   ->>then daily backup will get symlink from current success running monthly backup
#   ->>daily and weekly backup dont run if current monthly backup were success
#
# checks rotation credential and delete the oldest monthly backup Set
#
#--------------------------
# Weekly backup will do:
#--------------------------
# if weekly backup run success 
# than daily backup will get symlink from current success running weekly backup
#  ->>daily backup dont run if current weekly backup backup were success
#
# checksrotation credential and delete the oldest weekly backup set
#
#--------------------------
# Daily backup will do:
#--------------------------
# if weekly and monthly backup dont run current day 
#  ->>than daily will run success 
#
# checks rotation credential and delete the oldest daily backup set
#
#+--------------------------------------------------------------------------------------+



#sources to backup
src="/usr/local/nginx/html/wpsite/sites"

# backup destination
dest=/backups


# log file
backuplog=/var/log/backup.log

# rotation credentials
# the oldest set of every backup will be deleted
daily=14
weekly=3
monthly=2

#const 
jahrTag=$(date +%j)	# 244
kalWoche=$(date +%V)	# 45
heuteTag=$(date +%A)	# Sonntag
monatsTag=$(date +%d)	# 14
monat=$(date +%B)	# Nov
destSubPath="notSet"
sumOfDayBackups=0
sumOfWeekBackups=0
sumOfMonthBackups=0

# script debug
#echo $kalTag " " $kalWoche " " $heuteTag " " $monatsTag " " $monat
#echo $src " " $dest

initCheckBackup(){

	if [ ! -d "${dest}/monatBackup" ]; then
        	mkdir -p ${dest}/monatBackup
	fi

        if [ ! -d "${dest}/tagBackup" ]; then
		mkdir -p ${dest}/tagBackup
	fi

        if [ ! -d "${dest}/wocheBackup" ]; then
                mkdir -p ${dest}/wocheBackup
        fi

	sumOfDayBackups=$(ls -l ${dest}/tagBackup/ | grep -v total | wc -l)
        sumOfWeekBackups=$(ls -l ${dest}/wocheBackup/ | grep -v total | wc -l)
	sumOfMonthBackups=$(ls -l ${dest}/monatBackup/ | grep -v total | wc -l)	
}

executeBackup(){
	mysqldump -u root -pPW wpsite > $dest"/"$destSubPath/$(date +%d%m).sql	
	rsync --out-format=" %t %f %b " -avl --delete --stats --progress  --log-file="$backuplog" $src $dest"/"$destSubPath/  >> $backuplog 2>&1

}

tagesBackupSets(){

	destSubPath="tagBackup/"$heuteTag"-T"$monatsTag"-KW"$kalWoche

        if [ -d $dest"/wocheBackup/"$heuteTag"-KW"$kalWoche ]; then
                echo "=== wochen backup ist für == diesen Tag == vorhanden"  >> $backuplog
                exit
        fi


	if (( $sumOfDayBackups < $daily || $sumOfDayBackups == $daily ))
	then
	 mkdir $dest"/"$destSubPath  >> $backuplog 2>&1
	 executeBackup
	else
	echo "=== delete === oldest DailySet" >> $backuplog
	cd ${dest}/tagBackup/ && rm -rf $(ls -lht ${dest}/tagBackup/ | tail -n1 | awk '{print $9}')
	fi
}


wocheBackupSets(){

        destSubPath="wocheBackup/"$heuteTag"-KW"$kalWoche

	if [ -d $dest"/monatBackup/"$monat"-KW"$kalWoche"-"$heuteTag ]; then
		echo "=== monats backup ist für == diese woche == vorhanden"  >> $backuplog
		exit
	fi

        if (( $sumOfWeekBackups < $weekly || $sumOfWeekBackups == $weekly ))
        then
         mkdir $dest"/"$destSubPath >> $backuplog 2>&1
	 ln -s $dest"/"$destSubPath $dest"/tagBackup/"$heuteTag"-T"$monatsTag"-KW"$kalWoche >> $backuplog 2>&1 
         executeBackup
        else
        echo "=== delete === Oldest WeekSet" >> $backuplog
        cd ${dest}/wocheBackup/ && rm -rf $(ls -lht ${dest}/wocheBackup/ | tail -n1 | awk '{print $9}')
        fi
}

monatBackupSets(){

        destSubPath="monatBackup/"$monat"-KW"$kalWoche"-"$heuteTag
	
        if (( $sumOfMonthBackups < $monthly || $sumOfMonthBackups == $monthly ))
        then
         mkdir $dest"/"$destSubPath >> $backuplog 2>&1
	 ln -s $dest"/"$destSubPath $dest"/wocheBackup/"$heuteTag"-KW"$kalWoche >> $backuplog 2>&1
	 ln -s $dest"/"$destSubPath $dest"/tagBackup/"$heuteTag"-T"$monatsTag"-KW"$kalWoche >> $backuplog 2>&1
         executeBackup
        else
        echo "=== delete === Oldest MonthSet" >> $backuplog
        cd ${dest}/monatBackup/ && rm -rf $(ls -lht ${dest}/monatBackup/ | tail -n1 | awk '{print $9}')
        fi
}



initCheckBackup

if [[ "$1" == "monthly" ]]
  then
	monatBackupSets

  else if [[ "$1" == "weekly" ]]
  then
	wocheBackupSets

  else if [[ "$1" == "daily" ]]
  then
	tagesBackupSets

  else
	echo "falsche parameter  daily weekly oder monthly"
	exit 1
    fi
  fi
fi

#rsync -e 'ssh -p 30000' -avl --delete --stats --progress demo@123.45.67.890:/home/demo $dest/
