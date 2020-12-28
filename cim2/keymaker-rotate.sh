#!/bin/bash

# list public keys

aws iam list-users --query 'Users[].{UserName: UserName}' | grep UserName | awk -F ':' '{print $2}' | tr -d '"' > users.txt


for user in `cat users.txt`
do
aws iam list-ssh-public-keys  --user-name $user --query 'SSHPublicKeys[].{UploadDate: UploadDate}' |  egrep -o -E '"UploadDate":.{0,50}' | tr -d '"' |sed 's/UploadDate:/ /g' | sed 's/ //g' > date.txt

B=`cat date.txt`

datetime=$B
timeago='90 days ago'

dtSec=$(date --date "$datetime" +'%s')
taSec=$(date --date "$timeago" +'%s')

echo "INFO: dtSec=$dtSec, taSec=$taSec" >&2

if [ "$dtSec" -lt "$taSec" ]
then
 echo "SSH Pub Key is older than 90 days for $user"

 # makes the existing keys inactive
key=`aws iam list-ssh-public-keys  --user-name $user --query 'SSHPublicKeys[].{SSHPublicKeyId: SSHPublicKeyId}' |  egrep -o -E '"SSHPublicKeyId":.{0,50}' | tr -d '"' |sed 's/SSHPublicKeyId:/ /g' | sed 's/ //g'`

 aws iam update-ssh-public-key --user-name $user --ssh-public-key-id $key --status Inactive
fi
done
