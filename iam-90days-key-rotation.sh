#!/bin/bash


#REGIONS

declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for region in "${region[@]}"; do echo "$region"; done > /tmp/loc.txt

#90 days old

find /home -name id_rsa.pub -mtime +90 | awk -F "/" '{print $3}' > /tmp/iam.txt

Key_Gen_Pairs_New_USERS()
{
    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS

  for ldapusers in `cat /tmp/iam.txt`
  do
    echo $ldapusers
    if [ -f /home/$ldapusers/.ssh/id_rsa ]
    then
            mv /home/$ldapusers/.ssh/id_rsa /home/$ldapusers/.ssh/id_rsa_old
    else
            echo '/home/$ldapusers/.ssh/id_rsa is not there'
    fi


    #Generating a key pair

      ssh-keygen -f /home/$ldapusers/.ssh/id_rsa -t rsa -N '';
      cp /home/$ldapusers/.ssh/id_rsa.pub /home/$ldapusers/.ssh/authorized_keys
  done
}

Push_Key_OPS_Works()
{

  #Fetching IAM of an Ad user

  for new1 in `cat /tmp/ldapusers.txt`
  do
    iamusers=`ldapsearch -LLL -x -b "dc=freshsso,dc=com" -D "xxxxx" -h xxxx -w 'xxxx' "(&(objectClass=user)(cn=$new1))" | grep "mail" | cut -d ' ' -f2 | cut -d '@' -f1 | tr -d '.'`

    ldapsearch -LLL -x -b "dc=freshsso,dc=com" -D "xxxx" -h xxxx -w 'xxxxx' "(&(objectClass=user)(cn=$new1))" | grep memberOf | cut -d':' -f2 | cut -d',' -f1 | awk -F '=' {'print $2'} > /tmp/grp.txt

    #Fetching Group for an user

    for grp in `cat /tmp/grp.txt`
    do
      ldapsearch -x -b "dc=freshsso,dc=com" -D "xxxx" -h xxxx -w 'xxxx' "(&(objectClass=group)(cn=$grp))" | grep description | cut -d ":" -f2 | tr -d ' ' >> /tmp/acc_id.sh

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

     for re in `cat /tmp/loc.txt`
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
Key_Gen_Pairs_New_USERS
Push_Key_OPS_Works
