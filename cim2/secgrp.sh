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

read -p "region:" r


aws iam put-role-policy --role-name fusion_app --policy-name Describe-sec-grp --policy-document file://py.json

sleep 3



# Port 22
port22 ()
{
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='115.112.69.51/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='182.73.13.166/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='14.98.113.242/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='125.18.119.250/32' --query "SecurityGroups[*].[GroupId]"  --output text >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='115.114.112.82/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt

sleep 2
cat sec.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > 22.txt

cat 22.txt >> $ACC_ID.txt

echo > sec.txt

for sec in `cat 22.txt`
do
aws ec2 authorize-security-group-ingress   --group-id $sec  --region $r --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=13.234.188.229/32}] IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=137.83.204.108/32}] IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=139.180.249.233/32}] IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=3.105.76.219/32}] IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=139.180.251.239/32}] IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=13.52.196.116/32}]
done

}



# Port 80

port80()
{


aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='115.112.69.51/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='182.73.13.166/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='14.98.113.242/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='125.18.119.250/32' --query "SecurityGroups[*].[GroupId]"  --output text >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='115.114.112.82/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt

cat sec.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > 80.txt

echo > sec.txt

cat 80.txt >> $ACC_ID.txt

for sec in `cat 80.txt`
do
aws ec2 authorize-security-group-ingress   --group-id $sec  --region $r --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=13.234.188.229/32}] IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=137.83.204.108/32}] IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=139.180.249.233/32}] IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=3.105.76.219/32}] IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=139.180.251.239/32}] IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=13.52.196.116/32}]
done
}


# Port 443
port443()
{

aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='115.112.69.51/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='182.73.13.166/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='14.98.113.242/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='125.18.119.250/32' --query "SecurityGroups[*].[GroupId]"  --output text >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='115.114.112.82/32' --query "SecurityGroups[*].[GroupId]"  --output text  >> sec.txt

cat sec.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > 443.txt
echo > sec.txt
cat 443.txt >> $ACC_ID.txt

for sec in `cat 443.txt`
do
aws ec2 authorize-security-group-ingress   --group-id $sec  --region $r --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=13.234.188.229/32}] IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=137.83.204.108/32}] IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=139.180.249.233/32}] IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=3.105.76.219/32}] IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=139.180.251.239/32}] IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=13.52.196.116/32}]


done
}
port22
port80
port443

cat $ACC_ID.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > $ACC_ID-list.txt

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

done
