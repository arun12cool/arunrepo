#!/bin/bash
> rlist.csv
for acc_id in `cat acc.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/fusion_app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)
  role=`aws iam list-role-policies --role-name RevokeUnauthorisedSecurityGroupIngress --query 'PolicyNames[]' --output text`
      te=`aws iam get-role --role-name RevokeUnauthorisedSecurityGroupIngress --output text | grep PRINCIPAL`
       tg=`aws iam list-role-tags --role-name RevokeUnauthorisedSecurityGroupIngress --output text | grep -v "False" | tr '\n' ' ' | sed -r 's/(\w+ +){4}/&\n/g'`
        echo $acc_id "|" $role "|" $tg "|" $te  >> rlist.csv
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
