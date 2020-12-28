#!/bin/bash

chattr -R -a /home/*/session
du -sm /home/*/session/* | awk '$1 > 100' | awk '{print $2}' > /tmp/docker.txt
for i in `cat /tmp/docker.txt`
do
zip -r $i.zip $i

aws s3 ls | grep "screen-record" | awk -F " " '{print $3}' > /tmp/record.txt

sleep 2
for b in `cat /tmp/record.txt`
do
s3cmd sync $i.zip  s3://$b/$HOSTNAME/ >> /var/log/s3log 2>&1
done
rm -rf $i.zip
done
du -sm /home/*/session/* | awk '$1 > 100' | awk '{print $2}'| cut -d '/' -f5 > /tmp/logged.txt
who | cut -d' ' -f1 | sort | uniq > /tmp/who.txt
diff /tmp/logged.txt /tmp/who.txt |grep "<"|sed  's/< \+//g' > /tmp/logout.txt

for j in `cat /tmp/logout.txt`
do
rm -rf /home/$j/session/*
done

chattr -R +a /home/*/session
