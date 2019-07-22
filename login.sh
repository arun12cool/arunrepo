#!/bin/bash

ssh-add

a=
b=
c=
d=
e=
f=
g=

echo   "\x1B[31m1:$a"
echo   "\x1B[32m2:$b"
echo   "\x1B[33m3:$c"
echo   "\x1B[34m4:$d"
echo   "\x1B[35m5:$e"
echo   "\x1B[36m6:$f"
echo   "\x1B[33m7:$g"

echo  "\x1B[m"
echo "tap the number : $x "

read  x
if [ "$x" = "1" ]
then
echo "\x1B[33m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address

elif [ "$x" = "2" ]
then
echo "\x1B[33m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address

elif [ "$x" = "3" ]
then
echo "\x1B[32m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address

elif [ "$x" = "4" ]
then
echo "\x1B[32m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address

elif [ "$x" = "5" ]
then
echo "\x1B[32m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address
elif [ "$x" = "6" ]
then
echo "\x1B[32m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address

elif [ "$x" = "7" ]
then
echo "\x1B[32m1:$1:You \vare \vlogging \vinto \v"
echo  "\x1B[m"

ssh -A xxx@ip-address


else
echo "\x1B[92m1:enter the correct one"
echo  "\x1B[m"
fi
