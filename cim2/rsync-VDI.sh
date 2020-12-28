#!/bin/bash
ls /home | grep -v centos > usersad.txt
for i in `cat usersad.txt`
do
if [ -d /home/$i/.ssh ] && [ -f /home/$i/.ssh/id_rsa ]
then
echo "$i/.ssh directory and id_rsa exists"
else
mkdir -p /home/$i/.ssh
rsync -avz --no-perms --no-owner --no-group --rsync-path='/usr/bin/sudo /usr/bin/rsync'  rsync@keygen-server.freshpo.com:/home/"$i"/.ssh/ /home/"$i"/.ssh/
chown -R "$i:domain users" /home/"$i"/.ssh/
fi
done
