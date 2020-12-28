#!/bin/bash

> nhumanlist
> error.txt

for acc_id in `cat ac.txt`
do
   temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$acc_id:role/fusion_app --role-session-name "user-details")
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

    users_list=( `aws iam list-users  | grep UserName | awk -F ":" '{print $2}' | tr -d '",,',' '` )

        for user in "${users_list[@]}"
            do
        access_key=`aws iam list-access-keys --user-name $user --output text`
            if [  -z "$access_key" ]
            then
                echo $user
                    email=`cat userdb.csv | grep -i -w "^$user" | awk -F "=" '{print $2}'`
                        aws iam tag-user --user-name $user --tags '[{"Key": "own:primary","Value": "'"$email"'"},{"Key": "security:iam-entity_type","Value": "Human"}]' 2> err.txt
                        if [   -s err.txt ]
                        then
                        err=`cat err.txt`
                        echo $user "|" $acc_id "|" $err  >> error.txt
                        fi
            else
                        echo $user "|" $acc_id >>nhumanlist.txt
            fi
        done
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done


----------------------

Verification script (complete tagged human user list)


#!/bin/bash

> human.csv

for acc_id in `cat ac.txt`
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
            A=`aws iam list-user-tags --user-name $user --output text | grep -v "False" | tr '\n' ' ' | sed -r 's/(\w+ +){4}/&\n/g'`
            echo $acc_id "|" $user "|" $A >> human.csv
        done

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
done
