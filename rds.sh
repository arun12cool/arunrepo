#!/bin/bash

echo "Enter the RDS Details :"

read i

echo $i > test.txt

sed -i 's/$/.cfg/' test.txt

for i in `cat test.txt`;do sed -i 's/^/#/' $i;done

echo "contents of this $i RDS file has been commented"

cat test.txt > history.txt && echo > test.txt
