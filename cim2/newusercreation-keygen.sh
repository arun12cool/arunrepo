#!/bin/bash

#REGIONS
declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for i in "${region[@]}"; do echo "$i"; done > /tmp/regions1.txt
reg=`cat regions1.txt`
#Pulling new users
New_User_Creation()
{
  az ad group list --display-name aws-  | grep "displayName" | cut -d ":" -f2 | tr -d ' ','"',',' > /tmp/gp.txt
  for u in `cat /tmp/gp.txt`
  do
  az ad group member list --group $u | grep "userPrincipalName" | cut -d ":" -f2 | cut -d "@" -f1 | tr -d ' ','"',',' >> /tmp/new.sh
  done
  sort -u /tmp/new.sh > /tmp/new.txt
  ls /home | grep -v 'centos' | sort -u > /tmp/existing.txt

  diff /tmp/new.txt /tmp/existing.txt |grep "<"|sed  's/< \+//g' > /tmp/ldapusersnew.txt

  echo > /tmp/new.sh

  while read new
  do
    useradd $new
    mkdir /home/$new/.ssh
    chown -R "$new:$new" /home/$new
  done < /tmp/ldapusersnew.txt
}
Key_Gen_Pairs_New_USERS()
{
    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS
  for ldap in `cat /tmp/ldapusersnew.txt`
  do
    echo $ldap
    if [ -f /home/$ldap/.ssh/id_rsa ]
    then
            mv /home/$ldap/.ssh/id_rsa /home/$ldap/.ssh/id_rsa_old
    else
            echo '/home/$ldap/.ssh/id_rsa is not there'
    fi
    #Switching to user shell
    sudo su - "$ldap" sh -c "
      cat /dev/zero | ssh-keygen -q -N ''
      cp /home/$ldap/.ssh/id_rsa.pub /home/$ldap/.ssh/authorized_keys "
  done
}
New_User_Creation
Key_Gen_Pairs_New_USERS

