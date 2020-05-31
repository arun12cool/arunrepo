#!/bin/bash

declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for regions in "${region[@]}"; do echo "$regions"; done > /tmp/reg.txt

#Pulling new users
New_User_Creation()
{
ldapsearch -x -b "dc=freshsso,dc=com" -D "xxxx" -h xxxxx -w 'xxxxxxx' "(&(objectClass=group))" | grep name | cut -d ":" -f2 | tr -d ' '| grep  "^aws-" > /tmp/gp.txt
  for group in `cat /tmp/gp.txt`
  do
  ldapsearch -x -b "dc=freshsso,dc=com" -D "xxxx" -h xxxx -w 'xxxxxx' "(&(objectClass=user)(memberOf="CN=$group,CN=Users,DC=freshsso,DC=com"))" | grep "mail\|userPrincipalName" | cut -d" " -f2 | grep "freshsso.com" |cut -d '@' -f1  >> /tmp/new.sh
  done
  sort -u /tmp/new.sh > /tmp/new.txt
  ls /home | grep -v 'centos' | sort -u > /tmp/existing.txt

  diff /tmp/new.txt /tmp/existing.txt |grep "<"|sed  's/< \+//g' > /tmp/ldapusers.txt

#LOOP FOR NEW USER CREATION

while read new
  do
    mkdir /home/$new
    cd /home/$new
    mkdir .ssh
  done < /tmp/ldapusers.txt

  }


Key_Gen_Pairs_New_USERS()
{
    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS

  for ldap in `cat /tmp/ldapusers.txt`
  do
    echo $ldap
    if [ -f /home/$ldap/.ssh/id_rsa ]
    then
            mv /home/$ldap/.ssh/id_rsa /home/$ldap/.ssh/id_rsa_old
    else
            echo '/home/$ldap/.ssh/id_rsa is not there'
    fi


    #Generating a key pair

      ssh-keygen -f /home/$ldap/.ssh/id_rsa -t rsa -N '';
      cp /home/$ldap/.ssh/id_rsa.pub /home/$ldap/.ssh/authorized_keys
  done
}

Push_Key_OPS_Works()
{

  #Fetching IAM of an Ad user

  for new1 in `cat /tmp/ldapusers.txt`
  do
    iamusers=`ldapsearch -LLL -x -b "dc=freshsso,dc=com" -D "xxxx" -h xxxxx -w 'xxxxx' "(&(objectClass=user)(cn=$new1))" | grep "mail" | cut -d ' ' -f2 | cut -d '@' -f1 | tr -d '.'`

    ldapsearch -LLL -x -b "dc=freshsso,dc=com" -D "xxx" -h xxxx -w 'xxxx' "(&(objectClass=user)(cn=$new1))" | grep memberOf | cut -d':' -f2 | cut -d',' -f1 | awk -F '=' {'print $2'} > /tmp/grp.txt

    #Fetching Group for an user

    for grp in `cat /tmp/grp.txt`
    do
      ldapsearch -x -b "dc=freshsso,dc=com" -D "xxxx" -h xxxx -w 'xxxxx' "(&(objectClass=group)(cn=$grp))" | grep description | cut -d ":" -f2 | tr -d ' ' >> /tmp/acc_id.sh

      sort -u /tmp/acc_id.sh > /tmp/acc_id.txt

    done

    for ACC_ID in `cat /tmp/acc_id.txt`
    do
      aws sts assume-role --role-arn arn:aws:iam::$ACC_ID:role/fusion_app --role-session-name "newuser-key" > /tmp/sessions.txt
      A=`cat /tmp/sessions.txt | grep "AccessKeyId" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
      S=`cat /tmp/sessions.txt | grep "SecretAccessKey" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
      T=`cat /tmp/sessions.txt | grep "SessionToken" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
      export AWS_ACCESS_KEY_ID=$A
      export AWS_SECRET_ACCESS_KEY=$S
      export AWS_SESSION_TOKEN=$T
        echo $iamusers

        aws opsworks describe-user-profiles --region us-east-1 | grep $iamusers | grep "IamUserArn" | grep -v "role" | tr -d '"',','|cut -d':' -f2,3,4,5,6,7| sed 's/ //g' > /tmp/arn.txt

         arn=`cat /tmp/arn.txt`
         chmod 644 /home/$new1/.ssh/*
        auth=$(< /home/$new1/.ssh/id_rsa.pub)

     for re in `cat /tmp/reg.txt`
         do
         aws opsworks describe-user-profiles --region $re | grep "Name" | grep $iamusers | cut -d ':' -f2 | tr -d '"',',',' ' > /tmp/valid.txt

         if [[ -s /tmp/valid.txt ]]
          then
                  aws opsworks update-user-profile --iam-user-arn $arn --ssh-username $iamusers --ssh-public-key "$auth" --region $re
         else
         echo "$iamusers doesnt exist in $re"
         fi
        done

        chmod 600 /home/$new1/.ssh/*
        echo > /tmp/acc_id.txt
     done
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
  done
}
New_User_Creation
Key_Gen_Pairs_New_USERS
Push_Key_OPS_Works
