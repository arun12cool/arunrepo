#!/bin/bash
for acc_id in `cat ac.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)
aws iam put-role-policy --role-name app  --policy-name Opsworks-user-deletion --policy-document file://policy2.json
sleep 7
for j in `cat user.txt`;
do
sleep 3
for r in `cat regions.txt`;do aws opsworks --region $r describe-user-profiles | grep "IamUserArn" | grep -w "$j" | awk '{print $2}' | tr -d '"',',' > opsworks.txt;
for o in `cat opsworks.txt`; do aws opsworks --region $r delete-user-profile --iam-user-arn $o;done;done
done
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
