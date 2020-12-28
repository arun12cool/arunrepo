#!/bin/bash

> pol.csv

for acc_id in `cat acc.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/fusion_app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

    for role in `cat role`
    do

    echo $role

        r=`aws iam list-attached-role-policies --role-name $role | grep PolicyArn | awk -F " " '{print $2}' | tr -d '"' | cut -d "/" -f2`

        echo $acc_id "|" $role "|" $r "|" Managed  >> pol.csv


        l=`aws iam list-role-policies --role-name $role --query PolicyNames[] --output text`

        echo $acc_id "|" $role "|" $l "|" inline >> pol.csv


    done
 unset AWS_ACCESS_KEY_ID
 unset AWS_SECRET_ACCESS_KEY
 unset AWS_SESSION_TOKEN
done
