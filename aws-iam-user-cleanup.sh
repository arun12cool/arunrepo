#!/bin/bash

for i in `cat users.txt`; do aws iam list-access-keys --user-name $i | grep "UserName\|AccessKeyId" | grep "UserName" | tr -d '"',',' | awk -F ":" '{print $2}';done > test.txt

sort -u users.txt > te1.txt
sort -u test.txt > te2.txt

join -v1 -v2 te1.txt te2.txt > output.txt


for j in `cat output.txt`;
do
aws iam list-attached-user-policies --user-name $j | grep "PolicyArn" | awk '{print $2}' | tr -d '"' > policy.txt
for p in `cat policy.txt`;do aws iam detach-user-policy --user-name $j --policy-arn $p ; done;
aws iam list-user-policies --user-name $j | grep -v "PolicyNames" | tr -d '"',']','}','{',']' | awk '{print $1}' | awk '$1=$1' > 1.txt
for u in `cat 1.txt`;do aws iam delete-user-policy --user-name $j --policy-name $u;done
aws iam list-groups-for-user --user-name $j | grep "GroupName" |awk '{print $2}' | tr -d '"' > group.txt
for g in `cat group.txt`; do aws iam remove-user-from-group --user-name $j --group-name $g ; done;
aws iam delete-login-profile --user-name $j;
aws iam list-ssh-public-keys  --user-name $j | grep "SSHPublicKeyId" | awk '{print $2}' | tr -d '"',',' > sshkeys.txt
for s in `cat sshkeys.txt`;do aws iam delete-ssh-public-key --user-name $j --ssh-public-key-id $s;done;
aws iam list-virtual-mfa-devices | grep -w "$j" | grep "SerialNumber" | awk '{print $2}' | tr -d '"',',' > mfa.txt
for d in `cat mfa.txt`;do aws iam deactivate-mfa-device --user-name $j --serial-number $d;done;
for m in `cat mfa.txt`;do aws iam delete-virtual-mfa-device --serial-number $m;done;
for r in `cat regions.txt`;do aws opsworks --region $r describe-user-profiles | grep "IamUserArn" | grep -w "$j" | awk '{print $2}' | tr -d '"',',' > opsworks.txt;
for o in `cat opsworks.txt`; do aws opsworks --region $r delete-user-profile --iam-user-arn $o;done;done
aws iam delete-user --user-name $j;
done


