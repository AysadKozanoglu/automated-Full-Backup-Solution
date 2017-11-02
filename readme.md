### Automated full backup solution ###

  Author: Aysad Kozanoglu
  email : aysadx@gmail.com
 Version: 1.0

   (Türkiye / Germany)

 =============================
 Full automated Backup script
 daily weekly monthly backups 
 with backupSet Credentials
 =============================

 crontab credendials 
 (hold the steps below first monthly than Weekly and at last Daily)

 0  23 28-31 * * [ $(date -d +1day +%d) -eq 1 ] && backup.sh monthly 	
 20 23 * 6 backup.sh weekly
 30 23 * * backup.sh daily


--------------------------
 Monthly backup will do:
 -------------------------
 will run onyly between 28-31 days of Month and
 if the next day is the 1. day of next month, Monthly backup will run
  ->> see crontab example before^

 if monthly backup run success with the cron credentials 
 (cron will execute  only between 28-31 of the monthday)
   ->>then weekly backup will get symlink from current success running monthly backup
   ->>then daily backup will get symlink from current success running monthly backup
   ->>daily and weekly backup dont run if current monthly backup were success

 checks rotation credential and delete the oldest monthly backup Set

--------------------------
 Weekly backup will do:
--------------------------
 if weekly backup run success 
 than daily backup will get symlink from current success running weekly backup
  ->>daily backup dont run if current weekly backup backup were success

 checksrotation credential and delete the oldest weekly backup set

--------------------------
 Daily backup will do:
--------------------------
 if weekly and monthly backup dont run current day 
  ->>than daily will run success 

 checks rotation credential and delete the oldest daily backup set


