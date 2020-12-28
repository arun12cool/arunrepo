
#!/bin/bash

export VAULT_ADDR="http://vault-cloudinfra.freshpo.com:8200"

read -p "password:" pass

vault login -method=userpass username=$USER password=$pass

vault write ssh-client-signer/sign/$USER     public_key=@$HOME/.ssh/id_rsa.pub >/dev/null

vault write -field=signed_key ssh-client-signer/sign/$USER   public_key=@$HOME/.ssh/id_rsa.pub > signed-cert.pub

ssh-keygen -Lf signed-cert.pub | grep Valid


read -p "target server ip:" ip

read -p "username:" user

ssh -i signed-cert.pub -i ~/.ssh/id_rsa $user@$ip
