
-----

#!/bin/bash



for i in `cat bucket.txt`
do

aws sts assume-role --role-arn arn:aws:iam::$i:role/fusion_app --role-session-name "s3-lifecycle" > sessions.txt

A=`cat sessions.txt | grep "AccessKeyId" | awk -F':' '{print $2}'|tr -d '"'|awk '{$1=$1};1'`
S=`cat sessions.txt | grep "SecretAccessKey" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
T=`cat sessions.txt | grep "SessionToken" | awk -F':' '{print $2}'|tr -d '"',','|awk '{$1=$1};1'`
export AWS_ACCESS_KEY_ID=$A
export AWS_SECRET_ACCESS_KEY=$S
export AWS_SESSION_TOKEN=$T

aws iam put-role-policy --role-name fusion_app --policy-name s3-lifecycle-screen --policy-document file://life1.json
sleep 3

aws s3 ls | grep "screen-record" | awk -F " " '{print $3}' > record.txt

sleep 2
for j in `cat record.txt`
do

aws s3api put-bucket-lifecycle --bucket $j --lifecycle-configuration file://lifecycle.json
sleep 3

aws s3api get-bucket-lifecycle --bucket $j >> output.txt

echo "$j=$i" >> output.txt

done

aws iam delete-role-policy --role-name fusion_app --policy-name s3-lifecycle-screen


unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
done

-----------------------------------------------------------------------------------------------------

# IAM Policy

Name: life.sjon



{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetLifecycleConfiguration",
                "s3:ListAllMyBuckets",
                "s3:PutLifecycleConfiguration",
                "s3:ListBucket",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        }
    ]
}


# Glacier policy 

Name: lifecycle.json

{
	"Rules": [{
		"ID": "Move to Glacier after thirty days",
		"Prefix": "",
		"Status": "Enabled",
		"Transition": {
			"Days": 30,
			"StorageClass": "GLACIER"
		},
		"Expiration": {
			"Days": 335
		}
	}]
}
