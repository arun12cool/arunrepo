#!/bin/sh

# Your Email Information: Recipient (To:), Subject and Body
SUBJECT="Email from your Keygen Server: SSH Login Alert"

BODY="
The following SSH User has logged in to the Keygen server::
  	User:        	$PAM_USER
	User IP Host: 	$PAM_RHOST
	Service:      	$PAM_SERVICE
	Date:         	`date`
	Server:       	`echo $HOSTNAME`
"

if [ ${PAM_USER} != "rsync" -a ${PAM_TYPE} = "open_session" ]; then
(
echo "From: testm "
echo " "
echo "To: "
echo " "
echo "Subject:${SUBJECT}"
echo " "
echo "Content-Type: text"
echo ""
echo " ${BODY} "
echo " "
) | /usr/lib/sendmail -t
echo "$PAM_USER" from $PAM_RHOST has logged in to $HOSTNAME on `date` >> /var/log/loginalerts
fi

exit 0
