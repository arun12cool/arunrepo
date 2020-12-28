#!/bin/bash

export VAULT_ADDR="https://vault-cloudinfra.freshpo.com:8200"


read -p "vault username:" user

token="$HOME/.vault-token"

if [  -s $token ]
then
vault token lookup | grep $user > /dev/null
if [ $? -eq 0 ]
then
echo "There is a vault token generated for this user already"
else
echo " You have not authenticated to the vault even once, authenticate using your vault password"
vault login -method=userpass username=$user > /dev/null
fi
else
echo " You have not authenticated to the vault even once, authenticate using your vault password"
vault login -method=userpass username=$user > /dev/null
fi

    if [ -f $HOME/.ssh/id_rsa ]
    then
           echo " You have a key pair" > /dev/null
    else
        echo " you dont have a SSH keypair under .ssh directory , do create one using 'ssh-keygen' command and then re-execute this binary/script"
    fi

   read -p "Role/Stack name:" acc



vault write $acc/sign/$acc   public_key=@$HOME/.ssh/id_rsa.pub >/dev/null

vault write -field=signed_key $acc/sign/$acc   public_key=@$HOME/.ssh/id_rsa.pub > .ssh/id_rsa-cert.pub

if [ $? -eq 0 ]
then

session_key=`ssh-keygen -Lf .ssh/id_rsa-cert.pub | grep Valid`


echo "Login before it expires :  $session_key "

echo "Command :  ssh -i .ssh/id_rsa-cert.pub -i .ssh/id_rsa -A username@ip"


else


echo "Unable to sign the key, It could be due to the following reasons :
1) Permission Denied : Either you are using a different username or you do not have permissions to access it
or
2) Timeout : Try after a while , if it fails report to cloudinfra
or
3) Vault is unreachable , "telnet vault-cloudinfra.freshpo.com 8200", if it fails reach out to cloudinfra"

fi
