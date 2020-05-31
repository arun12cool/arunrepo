#!/bin/bash

x=`/usr/bin/curl -s http://internal-ocr-bg-monitoring-409474479.us-east-1.elb.amazonaws.com:80/dead_jobs?page=1 | egrep  -o -E '"count":.{0,20}' | tr -d '"',':','count'`

run_time=`date +%d-%m-%y`

/usr/bin/curl -s http://internal-ocr-bg-monitoring-409474479.us-east-1.elb.amazonaws.com:80/dead_jobs?page=1 | egrep 'name' | tr -d '"',',' > /root/name.txt

/usr/bin/curl -s http://internal-ocr-bg-monitoring-409474479.us-east-1.elb.amazonaws.com:80/dead_jobs?page=1 | egrep 'service' | tr -d '"',',' > /root/service.txt

paste -d '\n' /root/name.txt /root/service.txt  | xargs -d '\n' printf '%-30s  %-30s\n' > /root/test.txt
(
echo "From: freshdesk_user@freshpo.com "
echo " "
echo "To: noc@freshworks.com,fd-swatkats-engineering-team@freshworks.com,abinaya.sarathi@freshworks.com,arun.krishnakumar@freshworks.com"
echo " "
echo "Subject: Dead Jobs Queue :$x - Region : Us-east-1 - $run_time"
echo " "
echo "Content-Type: text"
echo ""
echo " Dead Jobs Queue :$x "
echo " "
cat /root/test.txt
echo " "
) | /usr/lib/sendmail -t
