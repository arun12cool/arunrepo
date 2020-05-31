curl -s -u nagiosadmin:nagiosadmin\:xxxx <url> | grep -w -A 22 "dashboard alert alert-danger"

grep -o -E '"id":[0-9]{0,20}' FL_2.txt | awk -F ":" '{print $2}'

curl -s -u nagiosadmin:nagiosadmin\:xxxx xxxxx |grep RDS.CPUUtilization |grep host_name |cut -d'?' -f2  | cut -d'=' -f2 | cut -d'&' -f1

ps -eo pcpu,pid,user,args  | sort -k1 -r -n | head -10

egrep -o -E '"accountId":.{0,20}' TEST.txt | awk -F ":" '{print $2}'| awk -F ',' '{print $1}' | sort -u | cut -c2-7

egrep --color -o '"id":[0-9]{11}'  TEST_1.txt | awk -F ":" '{print $2}'


curl  xxxxx | egrep -o -E '"count":.{0,20}'


aws iam list-users | egrep -o -E '"UserName":.{0,50}' | awk -F ":" '{print $2}' | tr -d '"',','

sed -e "s/.*/'&',/" full_acc.txt
sed -i 's/^/#/'


aws ec2 describe-instances --region eu-central-1  --instance-id $i --query 'Reservations[].Instances[].PrivateIpAddress' | grep -vE '\[|\]' | awk -F'"' '{ print $2 }';aws ec2 describe-tags --region us-east-1 --filters "Name=resource-id,Values=$i" "Name=key,Values=Name" --output text| cut -f5


