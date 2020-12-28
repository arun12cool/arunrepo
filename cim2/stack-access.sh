#!/bin/bash

read -p "Enter the SSO Name without "@freshworks.com": "  username

echo $username > /tmp/user.txt


  for new1 in `cat /tmp/user.txt`  #test
  do
    echo $new1 > /tmp/ad.txt
    sed -i 's/$/@freshworks.com/g' /tmp/ad.txt
    new3=`cat /tmp/adtest.txt`
    iamuser=`az ad user show --id $new3 | grep "mailNickname" | cut -d ":" -f2 | tr -d ' ','"',',','.'`
    echo "the IAM user name for the $username is :  $iamuser "

    read -p "Enter the AWS account Name(in lower case) : " accountname
    echo $accountname > /tmp/acc.txt
    acc=`cat /tmp/acc.txt`

    accountid=`grep -w "$acc" /tmp/accountlist.txt | cut -d "=" -f2`
    echo "the account ID for the $acc is :  $accountid "

    echo $accountid > /tmp/acc_id1.txt

      ACC_ID=`cat /tmp/acc_id1.txt`

       read -p "Enter the region(in lower case) : " region

        echo $region > /tmp/locuser.txt

        region=`cat /tmp/locuser.txt`

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',',' > /tmp/arn.txt

         arn=`cat /tmp/arn.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)

          aws opsworks --region $region create-user-profile  --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser 2>/dev/null
          aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $region

          echo "key  has been pushed in $region for the $iamuser"

        chmod 600 /home/$new1/.ssh/*

done
