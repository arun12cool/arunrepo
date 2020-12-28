#!/bin/bash




#REGIONS

declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for region in "${region[@]}"; do echo "$region"; done > regions.txt

#org

org-id="031429593201"

   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$org-id:role/fusion_app --role-session-name "user-exit")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

aws organizations list-accounts | grep "Id" | cut -d ':' -f2 | tr -d ' ','"',','  > accs.txt

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

#accounts

for acc_id in `cat accs.txt` ;
do


   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$org-id:role/fusion_app --role-session-name "user-exit")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)


read -p "Username:" user
U=`aws iam list-users --query 'Users[].{UserName: UserName}' --output=text | grep -w $user` >/dev/null
if [ -z "$U" ]
then
echo "it doesnt exist in $acc_id" 
else
echo "$user" >> userdel.txt
fi

	for j in `cat userdel.txt`;
	do
	aws iam list-attached-user-policies --user-name $j | grep "PolicyArn" | awk '{print $2}' | tr -d '"' > policy.txt  >>/dev/null
	sleep 1
		for p in `cat policy.txt`;do aws iam detach-user-policy --user-name $j --policy-arn $p ; done;
		aws iam list-user-policies --user-name $j | grep -v "PolicyNames" | tr -d '"',']','}','{',']' | awk '{print $1}' | awk '$1=$1' > 1.txt >>/dev/null
		sleep 1
			for u in `cat 1.txt`;do aws iam delete-user-policy --user-name $j --policy-name $u;done >>/dev/null
			aws iam list-groups-for-user --user-name $j | grep "GroupName" |awk '{print $2}' | tr -d '"' > group.txt >>/dev/null
			sleep 1
				for g in `cat group.txt`; do aws iam remove-user-from-group --user-name $j --group-name $g ; done; >>/dev/null
				sleep 1
				aws iam delete-login-profile --user-name $j; >>/dev/null 
				aws iam list-ssh-public-keys  --user-name $j | grep "SSHPublicKeyId" | awk '{print $2}' | tr -d '"',',' > sshkeys.txt >>/dev/null

				sleep 1
					for s in `cat sshkeys.txt`;do aws iam delete-ssh-public-key --user-name $j --ssh-public-key-id $s;done; >>/dev/null 
					aws iam list-virtual-mfa-devices | grep -w "$j" | grep "SerialNumber" | awk '{print $2}' | tr -d '"',',' > mfa.txt >>/dev/null

					sleep 1
						for d in `cat mfa.txt`;do aws iam deactivate-mfa-device --user-name $j --serial-number $d;done; >>/dev/null
							for m in `cat mfa.txt`;do aws iam delete-virtual-mfa-device --serial-number $m;done; >>/dev/null
								for r in `cat regions.txt`;do aws opsworks --region $r describe-user-profiles | grep "IamUserArn" | grep -w "$j" | awk '{print $2}' | tr -d '"',',' > opsworks.txt; >>/dev/null
								sleep 1
									for o in `cat opsworks.txt`; do aws opsworks --region $r delete-user-profile --iam-user-arn $o;done;done >>/dev/null
									sleep 1
									aws iam delete-user --user-name $j; 
									done

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
