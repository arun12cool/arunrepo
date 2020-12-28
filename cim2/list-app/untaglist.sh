#!/bin/bash

> untagged-humanusers.csv

for acc_id in `cat ac.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/fusion_app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)
    
    users_list=( `aws iam list-users  | grep UserName | awk -F ":" '{print $2}' | tr -d '",,',' '` )
        for user in "${users_list[@]}"
        do
        o=`aws iam list-user-tags --user-name $user | grep -w "security:iam-entity_type" | cut -d ":" -f2,3 | tr -d '",',' '`
          if [ -z "$o" ]
          then
            echo $acc_id "|" $user >> untagged-humanusers.csv
          fi
        done
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

if [ -s "untagged-humanusers.csv" ]
then
sendEmail -v -f freshworks_internal@freshdesk.com -s smtpout.freshdesk.com:587 -xu nagios_internal -xp xxxxxxxxxxxxx -t arun.krishnakumar@freshworks.com,varun.sampath@freshworks.com -u "IAM users untagged" -m "Users attached in the sheet below are untagged" -a untagged-humanusers.csv >> /var/log/sendemail
fi

done
