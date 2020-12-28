#!/bin/bash


#REGIONS

declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for region in "${region[@]}"; do echo "$region"; done > /tmp/loc.txt

#90 days old

find /home -name id_rsa.pub -mtime +90 | awk -F "/" '{print $3}' > /tmp/iam.txt     

Key_Gen_Pairs_New_USERS()
{
    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS

  for ldapuser in `cat /tmp/iam.txt`
  do
    echo $ldapuser
    if [ -f /home/$ldapuser/.ssh/id_rsa ]
    then
            mv /home/$ldapuser/.ssh/id_rsa /home/$ldapuser/.ssh/id_rsa_old
    else
            echo '/home/$ldapuser/.ssh/id_rsa is not there'
    fi

#Generating a key pair
      sudo su - "$ldapuser" sh -c "
      
      chmod 700 .ssh
      cd .ssh
      ssh-keygen -f id_rsa -t rsa -N '' "
  done
}



Push_Key_OPS_Works()
{



  #IF it is in a common group

    aws organizations list-accounts --profile $ACC_ID | grep "Id" | cut -d ':' -f2 | tr -d ' ','"',','  > /tmp/allacc_id.txt  #test
     sleep 3




  for new1 in `cat /tmp/iam.txt`
  do
    echo $new1 > /tmp/iamad.txt
    sed -i 's/$/@freshworks.com/g' /tmp/iamad.txt
    new3=`cat /tmp/iamad.txt`
    iamuser=`az ad user show --id $new3 | grep "mailNickname" | cut -d ":" -f2 | tr -d ' ','"',',','.'`
    sleep 2
    az ad user get-member-groups --id  $new3 | grep "aws-" | cut -d ":" -f2 | tr -d ' ','"',',' > /tmp/grp.txt
    sleep 2

    grep "aws-common" /tmp/grp.txt
    if [ $? -eq '0' ]
    then
      echo "User in a common group"

      for ACC_ID in `cat /tmp/allacc_id.txt` #test
      do

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',',' > /tmp/arn.txt
        sleep 3

         arn=`cat /tmp/arn.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)

          for re in `cat /tmp/loc.txt`
          do

          aws opsworks describe-user-profiles --profile $ACC_ID --region $re | grep "Name" | grep $iamuser | cut -d ':' -f2 | tr -d '"',',',' ' > /tmp/valid.txt
          sleep 3

            if [[ -s /tmp/valid.txt ]]
            then
                  aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $re
                  sleep 3
            else
            echo "$iamuser doesnt exist in $re"
            fi
          done

        chmod 600 /home/$new1/.ssh/*
      done





    else

    #Fetching Group for an user
    for grp in `cat /tmp/grp.txt`
    do
      az ad group show --group $grp | grep description | cut -d ":" -f2 | tr -d ' ','",,' >> /tmp/acc_id.sh
    done
    sort -u /tmp/acc_id.sh > /tmp/acc_id90.txt
    echo > /tmp/acc_id.sh
    sleep 2
    for ACC_ID in `cat /tmp/acc_id90.txt`
    do

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',','  > /tmp/arn.txt
         sleep 2
         arn=`cat /tmp/arn.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)

        for re in `cat /tmp/loc.txt`
         do
         aws opsworks describe-user-profiles --profile $ACC_ID --region $re | grep "Name" | grep $iamuser | cut -d ':' -f2 | tr -d '"',',',' '  > /tmp/valid.txt
          sleep2
         if [[ -s /tmp/valid.txt ]]
          then
                  aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $re
         sleep 3
         else
         echo "$iamusers doesnt exist in $re"
         fi
        done

        chmod 600 /home/$new1/.ssh/*
     done
    fi
  done

}
Key_Gen_Pairs_New_USERS
Push_Key_OPS_Works
