#!/bin/bash

aws sts assume-role --role-arn arn:aws:iam::xxxx:role/fusion_app --role-session-name "xxxxx" > sessions.txt

A=`cat sessions.txt | grep "AccessKeyId" | awk -F':' '{print $2}'|tr -d '"'|awk '{$1=$1};1'`
S=`cat sessions.txt | grep "SecretAccessKey" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
T=`cat sessions.txt | grep "SessionToken" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`

export AWS_ACCESS_KEY_ID=$A
export AWS_SECRET_ACCESS_KEY=$S
export AWS_SESSION_TOKEN=$T

for i in `cat ami.txt`;
do
for r in `cat regions.txt`;do aws ec2 describe-images --image-ids $i --region $r | grep "ImageId\|SnapshotId" | awk -F':' '{print $2}' | tr -d '"',',' | grep "snap" > snapshot.txt;aws ec2 deregister-image --image-id $i --region $r;
for s in `cat snapshot.txt`;
do
aws ec2 delete-snapshot --snapshot-id $s --region $r;echo $i $r $s >> amidel.txt;done;
done;
done

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
