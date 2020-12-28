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

#read -p "region:" r

r=eu-central-1
#aws iam put-role-policy --role-name fusion_app --policy-name Describe-sec-grp --policy-document file://py.json
#sleep 3

# Port 22
port22 ()
{
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='115.112.69.51/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='182.73.13.166/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='14.98.113.242/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='125.18.119.250/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=22 Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='115.114.112.82/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
sleep 2
cat sec.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > 2.txt
cat 2.txt >> ACC.txt
echo > sec.txt

}
# Port 80
port80()
{
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='115.112.69.51/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='182.73.13.166/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='14.98.113.242/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='125.18.119.250/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=80 Name=ip-permission.to-port,Values=80 Name=ip-permission.cidr,Values='115.114.112.82/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
cat sec.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > 8.txt
echo > sec.txt
cat 8.txt >> ACC.txt

}
# Port 443
port443()
{
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='115.112.69.51/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='182.73.13.166/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='14.98.113.242/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='125.18.119.250/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
aws ec2 describe-security-groups --region $r --filters Name=ip-permission.from-port,Values=443 Name=ip-permission.to-port,Values=443 Name=ip-permission.cidr,Values='115.114.112.82/32' --query "SecurityGroups[*].[GroupId,OwnerId]"  --output text | awk '{$1=$1}1' OFS="<" >> sec.txt
cat sec.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' > 43.txt
echo > sec.txt
cat 43.txt >> ACC.txt

}
port22
port80
port443
cat ACC.txt | sort | uniq | sort | sed -e 's/[\t ]//g;/^$/d' >> l.txt

echo > ACC.txt

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
done
