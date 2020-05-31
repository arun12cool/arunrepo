aws opsworks --region ap-south-1 describe-instances --stack-id c84e5afa-04ea-4310-9aec-c7c6c01f8645 | grep PrivateIp | tr -d '"',',',' ' | cut -d ':' -f2 > ips.txt

for i in `cat ips.txt`;do
ssh -o StrictHostKeyChecking=no $i 'sudo yum install ksh -y';
done
