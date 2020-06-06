#!/bin/bash

cat /var/log/sendEmail |grep "nagios@\|helpdesk@" | grep "`date +"%b %d %H" |sed 's/$/:/'`\|`date --date="30 minutes ago" +"%b %d %H %M"|sed 's/$/:/'`" > /root/lo.txt

    if [ -s /root/lo.txt ]
    then
        echo "Logs are available and Emails are working fine" >>/dev/null
    else
        echo "Log file is empty, there are no logs for the past half an hour" >>/dev/null
(
echo "From:  "
echo " "
echo "To: "
echo " "
echo "Subject: Mails are failing - "
echo " "
echo "Content-Type: text"
echo ""
echo " Log file is empty, there are no logs for the past half an hour "
echo " "
cat /root/lo.txt
echo " "
) | /usr/lib/sendmail -t
fi
