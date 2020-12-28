#!/bin/bash
> tags.txt
> nhum.txt
> Noownuser.txt
> Nodescuser.txt
for acc_id in `cat acc.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/fusion_app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)
	users_list=( `aws iam list-users  | grep UserName | awk -F ":" '{print $2}' | tr -d '",,',' '` )
		for user in "${users_list[@]}"
    	do
		access_key=`aws iam list-access-keys --user-name $user --output text`
			if [ ! -z "$access_key" ]
			then
      			echo $user "|" $acc_id >> nhum.txt
				Owner=`aws iam list-user-tags --user-name $user --query 'Tags[].{Key:Key,Value:Value}' --output text | grep "Owner" | awk -F " " '{print $2}'`
				if [  -z "$Owner" ]; then  echo $user "|" $acc_id >> Noownuser.txt; fi
				Description=`aws iam list-user-tags --user-name $user --query 'Tags[].{Key:Key,Value:Value}' | grep -A2 -B2 "Description" | grep Value | awk -F ":" '{print $2}' | tr -d '",'| awk '$1=$1'`
				if [  -z "$Description" ]; then  echo $user "|" $acc_id >> Nodescuser.txt; fi
		                 aws iam tag-user --user-name $user --tags '[{"Key": "own:team","Value": "'"$Owner"'"},{"Key": "own:comment","Value": "'"$Description"'"},{"Key": "security:iam-entity_type","Value": "Service"}]'
			fi
		done
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
