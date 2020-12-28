#!/bin/bash
for acc_id in `cat acc1.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/fusion_app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)
aws iam create-role --role-name RevokeUnauthorisedSecurityGroupIngress --assume-role-policy-document file://role_policy.json
aws iam put-role-policy --role-name fusion_app  --policy-name Describe-sec-grp --policy-document file://policy2.json
aws iam put-role-policy --role-name RevokeUnauthorisedSecurityGroupIngress  --policy-name SecGpEditPolicy --policy-document file://policy.json
aws iam tag-role --role-name RevokeUnauthorisedSecurityGroupIngress --tags '[{"Key": "own:team","Value": "cloudinfra@freshworks.com"},{"Key": "own:comment","Value": "Used to remove the open security group."},{"Key": "security:iam-entity_type","Value": "Service"}]'
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
