#!/bin/bash
ls /home | grep -v centos > usersad.txt
for i in `cat usersad.txt`
do
if [ -d /home/$i/.ssh ]
then
echo "$i/.ssh directory exists"
else
mkdir -p /home/$i/.ssh
rsync -avzp --rsync-path='/usr/bin/sudo /usr/bin/rsync'  rsync@xxxxx:/home/"$i"/.ssh/ /home/"$i"/.ssh/
fi
done
