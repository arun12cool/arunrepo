aws opsworks --region ap-south-1 describe-instances --stack-id xxxxx | grep PrivateIp | tr -d '"',',',' ' | cut -d ':' -f2 > ips.txt

for i in `cat ips.txt`;do
ssh -o StrictHostKeyChecking=no $i 'sudo yum install ksh -y';
done
