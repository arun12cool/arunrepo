#!/bin/bash

> appusers.txt
> tags.csv
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
			if [ -z "$access_key" ] 
			then
      			echo $user >/dev/null

			else
      			tag=`aws iam list-user-tags --user-name $user --output text | grep -v "False" | tr '\n' ' ' | sed -r 's/(\w+ +){4}/&\n/g'`
      			keys=`aws iam list-access-keys --user-name $user --output text | grep -A2 "Inactive"`

      				if [ -z "$keys" ] 
	  				then
      #tag=`aws iam list-user-tags --user-name $user --output text | grep -v "False" | tr '\n' ' ' | sed -r 's/(\w+ +){4}/&\n/g'`
      					echo $acc_id "|" $user "|"  $tag >> tags.csv
      				else
    
      #tags=`aws iam list-user-tags --user-name $user --output text | grep -v "False" | tr '\n' ' ' | sed -r 's/(\w+ +){4}/&\n/g'` 
      				echo $acc_id "|" $user "|" $tag "|" $keys >> tags.csv
      				fi
			fi 

		done
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
