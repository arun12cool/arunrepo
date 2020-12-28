
#!/bin/bash

function session() {


sudo yum install util-linux -y 


/bin/echo ' 
if [ "x$SESSION_RECORD" = "x" ]
then
timestamp=$(date +%d-%m-%Y-%T)
if [ ! -d /var/log/session/$USER ]; then
mkdir /var/log/session/$USER
else
echo "Recording $USER session"
fi
session_log=/var/log/session/$USER/session.$USER.$$.$timestamp.log
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
yum install wget tar unzip -y 2>/dev/null

wget https://sourceforge.net/projects/s3tools/files/s3cmd/2.0.1/s3cmd-2.0.1.tar.gz
tar xzf s3cmd-2.0.1.tar.gz
cd s3cmd-2.0.1
sudo python setup.py install

cat <<E"O"F >> /root/rotate.sh

#!/bin/bash

region=`cat /etc/motd | grep "EC2 Region" | awk -F':' '{print $2}' | tr -d ' '` 
id=`cat /etc/motd | grep "EC2 Instance ID" | awk -F':' '{print $2}' | tr -d ' '`


cd /var/log/session

du -sm * | awk '$1 > 100' | awk '{print $2}' > /tmp/folder.txt
for i in `cat /tmp/folder.txt`
do
zip -r $i.zip $i

aws s3 ls | grep "screen-record" | awk -F " " '{print $3}' > record.txt

sleep 2
for b in `cat record.txt`
do
s3cmd sync $i.zip  s3://$b/$HOSTNAME-$region-$id/ >> /var/log/s3log 2>&1
done
rm -rf $i.zip
who | cut -d' ' -f1 | sort | uniq > /tmp/who.txt
for j in `cat /tmp/who.txt`
do
grep $i /tmp/who.txt
if [ $? -eq 0 ]
then
echo "User is logged in"
else
rm -rf $i
fi
done
done

EOF

chmod +x /root/rotate.sh

/bin/echo '0 * * * *  sh /root/rotate.sh' >> /var/spool/cron/root

}

function logrotate_cron_docker() {

cat <<E"O"F >> /root/docker-rotate.sh

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
EOF

chmod +x /root/docker-rotate.sh

/bin/echo '0 * * * *  sh /root/docker-rotate.sh' >> /var/spool/cron/root

}
session
logrotate_cron
logrotate_cron_docker
