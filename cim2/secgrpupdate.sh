#!/bin/bash

echo > complete-list.txt
echo > error.txt


for ACC_ID in `cat /tmp/acc_id.txt`
do
    temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$ACC_ID:role/fusion_app --role-session-name "vpc-details")
    unset AWS_PROFILE
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

r=us-west-2

# Policy Attachment

echo $ACC_ID >> error.txt
aws iam put-role-policy --role-name fusion_app --policy-name Describe-sec-grp --policy-document file://py.json  >> error.txt

# Fetching group-id's and updating new IP's to the security group

check_and_update ()

{

echo > group-id.txt
#echo $1
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=$1 Name=ip-permission.to-port,Values=$1 Name=ip-permission.cidr,Values='115.112.69.51/32,182.73.13.166/32,14.98.113.242/32,125.18.119.250/32,115.114.112.82/32' --query "SecurityGroups[*].[GroupId]" --output text  > group-id.txt 2>>error.txt

for sec in `cat group-id.txt`
do
#aws ec2 authorize-security-group-ingress   --group-id $sec  --region $r --ip-permissions IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges=[{CidrIp=13.234.188.229/32,Description="GPCloudserviceVPN"}] IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges=[{CidrIp=137.83.204.108/32,Description="GPCloudserviceVPN"}] IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges=[{CidrIp=139.180.249.233/32,Description="GPCloudserviceVPN"}] IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges=[{CidrIp=3.105.76.219/32,Description="GPCloudserviceVPN"}] IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges=[{CidrIp=139.180.251.239/32,Description="GPCloudserviceVPN"}] IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges=[{CidrIp=13.52.196.116/32,Description="GPCloudserviceVPN"}] >> error.txt

aws ec2 authorize-security-group-ingress   --group-id $sec  --region $r --ip-permissions IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges='[{CidrIp=13.234.188.229/32,Description="GP-Cloudservice-VPN-IP"}]' IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges='[{CidrIp=137.83.204.108/32,Description="GP-Cloudservice-VPN-IP"}]' IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges='[{CidrIp=139.180.249.233/32,Description="GP-Cloudservice-VPN-IP"}]' IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges='[{CidrIp=3.105.76.219/32,Description="GP-Cloudservice-VPN-IP"}]' IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges='[{CidrIp=139.180.251.239/32,Description="GP-Cloudservice-VPN-IP"}]' IpProtocol=tcp,FromPort=$1,ToPort=$1,IpRanges='[{CidrIp=13.52.196.116/32,Description="GP-Cloudservice-VPN-IP"}]' >> error.txt

done


cat group-id.txt   >> complete-list.txt

}
check_and_update 22
check_and_update 80
check_and_update 443

sort -u -o complete-list.txt complete-list.txt

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

done
