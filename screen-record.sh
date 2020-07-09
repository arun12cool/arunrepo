
#!/bin/bash

function session() {


sudo yum install util-linux -y 


/bin/echo ' 
if [ "x$SESSION_RECORD" = "x" ]
then
timestamp=$(date +%d-%m-%Y-%T)
session_log=/var/log/session/session.$USER.$$.$timestamp.log
SESSION_RECORD=started
export SESSION_RECORD
script -t -f -q 2>${session_log}.timing $session_log
exit
fi' >> /etc/profile

mkdir /var/log/session

chmod +x /var/log/session/
chmod 777 /var/log/session/

}

function logrotate_cron() {

cd /root
yum install wget python tar unzip -y 2>/dev/null

wget https://sourceforge.net/projects/s3tools/files/s3cmd/2.0.1/s3cmd-2.0.1.tar.gz
tar xzf s3cmd-2.0.1.tar.gz
cd s3cmd-2.0.1
sudo python setup.py install

/bin/echo "/var/log/session/*{
  compress
  size 1M
  nomail
  missingok
  dateext
  dateformat -%Y-%m-%d-%s
  copytruncate
  nodelaycompress
  notifempty
  rotate 3
  sharedscripts
  lastaction
  s3cmd sync /var/log/session/*.gz s3://screen-record/$HOSTNAME/ >> /var/log/s3log 2>&1
  endscript
}" > /etc/logrotate.d/screen-record

/bin/echo "*/15 * * * *  /usr/sbin/logrotate /etc/logrotate.d/screen-record" >> /var/spool/cron/root
service crond reload
}
session
logrotate_cron
