#!/bin/bash

 for new1 in `cat /tmp/ldapusersmig.txt`  #test
  do
    echo $new1 > /tmp/adiammig.txt
    sed -i 's/$/@freshworks.com/g' /tmp/adiammig.txt
    new3=`cat /tmp/adiammig.txt`
    iamuser=`az ad user show --id $new3 | grep "mailNickname" | cut -d ":" -f2 | tr -d ' ','"',',','.'`

    for ACC_ID in `cat /tmp/acc_idmig.txt`
    do

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',',' > /tmp/arnmig.txt

         arn=`cat /tmp/arnmig.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)
         for re in `cat /tmp/locmig.txt`
          do

          aws opsworks --region $re create-user-profile  --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamusers
          aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $re

          done

        chmod 600 /home/$new1/.ssh/*
     done

  done
