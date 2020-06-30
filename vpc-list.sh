#!/bin/bash

for ACC_ID in `cat /tmp/acc_id.txt`
do
aws sts assume-role --role-arn arn:aws:iam::$ACC_ID:role/fusion_app --role-session-name "vpc-details" > sessions.txt

A=`cat sessions.txt | grep "AccessKeyId" | awk -F':' '{print $2}'|tr -d '"'|awk '{$1=$1};1'`
S=`cat sessions.txt | grep "SecretAccessKey" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
T=`cat sessions.txt | grep "SessionToken" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`

export AWS_ACCESS_KEY_ID=$A
export AWS_SECRET_ACCESS_KEY=$S
export AWS_SESSION_TOKEN=$T

for r in `cat regions.txt`
do
aws ec2 describe-vpcs --region $r --query 'Vpcs[].{VpcId:VpcId,CidrBlock:CidrBlock,OwnerId:OwnerId}' --output=text | awk -F' ' '{print $2"|"$3"|"$1}' > vpc.txt
for v in `cat vpc.txt`
do
echo $v"|"$r
done  >> vpcdetails.txt
done


unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
done
