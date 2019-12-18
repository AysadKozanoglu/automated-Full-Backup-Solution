### Automated full backup solution ###

  Author: Aysad Kozanoglu
  email : aysadx@gmail.com
 Version: 1.0

   (Türkiye / Germany)

 
 Full automated Backup script
 daily weekly monthly backups 
 with backupSet Credentials
 

 crontab credendials 
 (hold the steps below first monthly than Weekly and at last Daily)
<pre>
0  23 28-31 * * [ $(date -d +1day +%d) -eq 1 ] && /source/automated-Full-Backup-Solution/backup.sh monthly   
20 23 * * 7 /source/automated-Full-Backup-Solution/backup.sh weekly
30 23 * * * /source/automated-Full-Backup-Solution/backup.sh daily

</pre>


## Monthly backup will do ##
 
 will run onyly between 28-31 days of Month and
 if the next day is the 1. day of next month, Monthly backup will run
  ->> see crontab example before^

 if monthly backup run success with the cron credentials 
 (cron will execute  only between 28-31 of the monthday)
   ->>then weekly backup will get symlink from current success running monthly backup
   ->>then daily backup will get symlink from current success running monthly backup
   ->>daily and weekly backup dont run if current monthly backup were success

 checks rotation credential and delete the oldest monthly backup Set


 ## Weekly backup will do ##

 if weekly backup run success 
 than daily backup will get symlink from current success running weekly backup
  ->>daily backup dont run if current weekly backup backup were success

 checksrotation credential and delete the oldest weekly backup set


 ## Daily backup will do ##

 if weekly and monthly backup dont run current day 
  ->>than daily will run success 

 checks rotation credential and delete the oldest daily backup set




<pre>
Copyright 2017 Aysad Kozanoglu

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
</pre>

