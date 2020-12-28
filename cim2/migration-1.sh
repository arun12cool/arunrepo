#!/bin/bash
#REGIONS
declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for regions in "${region[@]}"; do echo "$regions"; done > /tmp/locmig.txt

#Pulling new users
New_User_Creation()
{

   # fetching group :  az ad group list --display-name aws-  | grep "displayName" | cut -d ":" -f2 | tr -d ' ','"',','

  for u in `cat /root/group-staging.txt`  #manual
  do
  az ad group member list --group $u | grep "userPrincipalName" | cut -d ":" -f2 | cut -d "@" -f1 | tr -d ' ','"',',' >> /tmp/newmig.sh  #manual if required.
  done
  sort -u /tmp/newmig.sh > /tmp/newmig.txt
  ls /home | grep -v 'centos\|rsync\|keymaker' | sort -u > /tmp/existingmig.txt

  diff /tmp/newmig.txt /tmp/existingmig.txt |grep "<"|sed  's/< \+//g' > /tmp/ldapusersmig.txt

  echo > /tmp/newmig.sh

  while read new
  do
    useradd $new
    cd /home/$new
    mkdir .ssh
    chown -R "$new:$new" .ssh

  done < /tmp/ldapusersmig.txt

  }


   Key_Gen_Pairs_New_USERS()
   {

    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS

  for ldap in `cat /tmp/ldapusersmig.txt` #test
  do
    echo $ldap
    if [ -f /home/$ldap/.ssh/id_rsa ]
    then
            mv /home/$ldap/.ssh/id_rsa /home/$ldap/.ssh/id_rsa_old
    else
            echo '/home/$ldap/.ssh/id_rsa is not there'
    fi


    #Generating a key pair
      sudo su - "$ldap" sh -c "

      chmod 700 .ssh
      cd .ssh
      ssh-keygen -f id_rsa -t rsa -N '' "
  done
