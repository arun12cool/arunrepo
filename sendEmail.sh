#!/bin/bash

cat /var/log/sendEmail |grep "nagios@\|helpdesk@" | grep "`date +"%b %d %H" |sed 's/$/:/'`\|`date --date="1 hour ago" +"%b %d %H"|sed 's/$/:/'`" > /root/lo.txt

    if [ -s /root/lo.txt ]
    then
        echo "Logs are available and Emails are working fine"
    else
        echo "Log file is empty, there are no logs for the past half an hour"
(
echo "From: xxxx "
echo " "
echo "To: xxxxx"
echo " "
echo "Subject: Mails are failing - Platforms-Ocr-Prod"
echo " "
echo "Content-Type: text"
echo ""
echo " Log file is empty, there are no logs for the past half an hour "
echo " "
cat /root/lo.txt
echo " "
) | /usr/lib/sendmail -t
fi
