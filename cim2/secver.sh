#!/bin/bash

echo > verified-list.txt
echo > err.txt
echo > missinglist.txt
echo > total-list.txt

for ACC_ID in `cat /tmp/acc_id.txt`
do
    temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$ACC_ID:role/fusion_app --role-session-name "vpc-details")
    unset AWS_PROFILE
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

r=us-west-2


echo $ACC_ID >> err.txt




verification ()

{

# List

echo > list-sec.sh
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values='22,80,443' Name=ip-permission.to-port,Values='22,80,443' Name=ip-permission.cidr,Values='115.112.69.51/32,182.73.13.166/32,14.98.113.242/32,125.18.119.250/32,115.114.112.82/32' --query "SecurityGroups[*].[GroupId,OwnerId]" --output text > list-sec.sh 2>>err.txt


# Verification

echo > sgid.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values='22,80,443' Name=ip-permission.to-port,Values='22,80,443' Name=ip-permission.cidr,Values='137.83.204.108/32,139.180.251.239/32,3.105.76.219/32,139.180.249.233/32,13.234.188.229/32,13.52.196.116/32' --query "SecurityGroups[*].[GroupId,OwnerId]" --output text > sgid.txt 2>>err.txt


}
verification

# difference btw total and updated

cat list-sec.sh | sort | uniq | sort  >> total-list.txt
cat sgid.txt | sort | uniq | sort   >> verified-list.txt

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

done
diff total-list.txt verified-list.txt |grep "<"|sed  's/< \+//g' >> missinglist.txt

echo "missing security groups from total : `cat missinglist.txt`"
