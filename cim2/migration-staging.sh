#!/bin/bash
#REGIONS
declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for regions in "${region[@]}"; do echo "$regions"; done > /tmp/locmig.txt

#Pulling new users
New_User_Creation()
{

   # fetching group :  az ad group list --display-name aws-  | grep "displayName" | cut -d ":" -f2 | tr -d ' ','"',','
   
  for u in `cat /root/group-staging.txt`  #manual
  do
  az ad group member list --group $u | grep "userPrincipalName" | cut -d ":" -f2 | cut -d "@" -f1 | tr -d ' ','"',',' >> /tmp/newmig.sh  #manual if required.
  done
  sort -u /tmp/newmig.sh > /tmp/newmig.txt
  ls /home | grep -v 'centos\|rsync\|keymaker' | sort -u > /tmp/existingmig.txt

  diff /tmp/newmig.txt /tmp/existingmig.txt |grep "<"|sed  's/< \+//g' > /tmp/ldapusersmig.txt

  echo > /tmp/newmig.sh

  while read new
  do
    useradd $new
    cd /home/$new
    mkdir .ssh
    chown -R "$new:$new" .ssh

  done < /tmp/ldapusersmig.txt

  }


   Key_Gen_Pairs_New_USERS()
   {
    
    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS

  for ldap in `cat /tmp/ldapusersmig.txt` #test
  do
    echo $ldap
    if [ -f /home/$ldap/.ssh/id_rsa ]
    then
            mv /home/$ldap/.ssh/id_rsa /home/$ldap/.ssh/id_rsa_old
    else
            echo '/home/$ldap/.ssh/id_rsa is not there'
    fi


    #Generating a key pair
      sudo su - "$ldap" sh -c "
      
      chmod 700 .ssh
      cd .ssh
      ssh-keygen -f id_rsa -t rsa -N '' "
  done
}


Push_Key_OPS_Works()
{

  for new1 in `cat /tmp/ldapusersmig.txt`  #test
  do  
    echo $new1 > /tmp/adiammig.txt
    sed -i 's/$/@freshworks.com/g' /tmp/adiammig.txt
    new3=`cat /tmp/adiammig.txt`
    iamuser=`az ad user show --id $new3 | grep "mailNickname" | cut -d ":" -f2 | tr -d ' ','"',',','.'`
    az ad user get-member-groups --id  $new3 | grep "aws-" | cut -d ":" -f2 | tr -d ' ','"',',' > /tmp/grpmig.txt

    grep "aws-common" /tmp/grpmig.txt
    if [ $? -eq '0' ]
    then
      echo "User in a common group"

      for ACC_ID in `cat /tmp/acc_staging_id.txt`    #manual
      do
    

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',',' > /tmp/arnmig.txt

         arn=`cat /tmp/arnmig.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)

          for re in `cat /tmp/locmig.txt`
          do
           
          aws opsworks --region $re create-user-profile  --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamusers  2>/dev/null
          aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $re
          
          
          done

        chmod 600 /home/$new1/.ssh/*
      done
        





    else

    #Fetching Group for an user

    for grp in `cat /tmp/grpmig.txt`
    do
      az ad group show --group $grp | grep description | cut -d ":" -f2 | tr -d ' ','",,' >> /tmp/acc_id.sh
    done 
    sort -u /tmp/acc_id.sh > /tmp/acc_idmig.txt
    echo > /tmp/acc_id.sh

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
        
    fi
  done
}
New_User_Creation
Key_Gen_Pairs_New_USERS
Push_Key_OPS_Works


