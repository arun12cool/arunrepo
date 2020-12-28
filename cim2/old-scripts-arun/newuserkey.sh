#!/bin/bash
#REGIONS
declare -a region=( us-east-1 eu-central-1 ap-south-1 ap-southeast-2 )
for regions in "${region[@]}"; do echo "$regions"; done > /tmp/reg.txt

#Pulling new users
New_User_Creation()
{

   DATE=`date --date="1 hour ago" '+%Y-%m-%dT%H:%M:%SZ'`

   az ad user list --filter "createdDateTime ge datetime'$DATE'" |  grep "userPrincipalName" | cut -d ":" -f2  | tr -d ' ','"',',' > /tmp/newusers.txt

   if [[ ! -s /tmp/newusers.txt ]]
   then
    echo "There are no AD users created in the past two hours"
  else
   for iam in `cat /tmp/newusers.txt`
   do
  az ad user get-member-groups --id  $iam | grep "aws-" | cut -d ":" -f2 | tr -d ' ','"',',' > /tmp/gpusers.txt
  sleep2
   if [[  -s /tmp/gpusers.txt ]]
   then   
    echo $iam >> /tmp/new.sh
  else
    echo "There are no new users added to any of our AWS groups"
fi
done
fi


  cat /tmp/new.sh | cut -d "@" -f1 | sort -u > /tmp/new.txt
  ls /home | grep -v 'centos\|rsync' | sort -u > /tmp/existing.txt

  diff /tmp/new.txt /tmp/existing.txt |grep "<"|sed  's/< \+//g' > /tmp/ldapusers.txt
   
     echo > /tmp/new.sh


  

#LOOP FOR NEW USER CREATION

while read new
  do
    useradd $new
    cd /home/$new
    mkdir .ssh
   chown -R "$new:$new" .ssh

  done < /tmp/ldapusers.txt    

  }


Key_Gen_Pairs_New_USERS()
{
    #LOOP FOR GENERATING KEY PAIRS FOR NEW USERS

  for ldap in `cat /tmp/ldapusers.txt` 
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



  #If it is in a common group
   

      aws organizations list-accounts --profile $ACC_ID | grep "Id" | cut -d ':' -f2 | tr -d ' ','"',',' > /tmp/allacc_id.txt
      sleep2
  
  for new1 in `cat /tmp/ldapusers.txt`  #test
  do  
    echo $new1 > /tmp/adiam.txt
    sed -i 's/$/@freshworks.com/g' /tmp/adiam.txt
    new3=`cat /tmp/iamad.txt`
    iamuser=`az ad user show --id $new3 | grep "mailNickname" | cut -d ":" -f2 | tr -d ' ','"',',','.'`
    az ad user get-member-groups --id  $new3 | grep "aws-" | cut -d ":" -f2 | tr -d ' ','"',',' > /tmp/grpnew.txt
    sleep2

    grep "aws-common" /tmp/grpnew.txt
    if [ $? -eq '0' ]
    then
      echo "User in a common group"

      for ACC_ID in `cat /tmp/allacc_id.txt`
      do
    

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',',' > /tmp/arn.txt
         sleep2
         arn=`cat /tmp/arn.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)

          for re in `cat /tmp/loc.txt`
          do
           
          aws opsworks --region $re create-user-profile  --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamusers  2>/dev/null
          sleep3
          aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $re
          sleep2
          done

        chmod 600 /home/$new1/.ssh/*
        done
       

    else

    #Fetching Group for an user

    for grp in `cat /tmp/grpnew.txt`
    do
      az ad group show --group $grp | grep description | cut -d ":" -f2 | tr -d ' ','",,' >> /tmp/acc_id.sh
      sleep2
    done 
    sort -u /tmp/acc_id.sh > /tmp/acc_id1.txt
    echo > /tmp/acc_id.sh

    for ACC_ID in `cat /tmp/acc_id90.txt`
    do
      

        echo $iamuser

        aws iam get-user --profile $ACC_ID --user-name $iamuser | grep "Arn" | cut -d':' -f2,3,4,5,6,7| sed 's/ //g' | tr -d '"',',' > /tmp/arn.txt
         sleep2
         arn=`cat /tmp/arn.txt`
         chmod 644 /home/$new1/.ssh/*
         auth=$(< /home/$new1/.ssh/id_rsa.pub)
         for re in `cat /tmp/loc.txt`
          do
      
          aws opsworks --region $re create-user-profile  --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamusers
          sleep3
          aws opsworks update-user-profile --profile $ACC_ID --iam-user-arn $arn --ssh-username $iamuser --ssh-public-key "$auth" --region $re
            sleep2 
          done

        chmod 600 /home/$new1/.ssh/*
     done
        fi
  done
}
New_User_Creation
Key_Gen_Pairs_New_USERS
Push_Key_OPS_Works
