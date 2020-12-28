#!/bin/bash
######################################################
#                                                    #
#  Screen Recorder and Haystack Agent health check.   #
#                                                    #
######################################################
# Screen Record Monitoring
screen_record()
{
        # screen record check
        >/root/screen-log.txt
        ENV=`\env | grep SESSION_RECORD | cut -d "=" -f2`
        if [ $ENV == "started" ]
        then
                echo $ENV
                echo "SESSION_RECORD is running for the ec2-user in $IP `date +%F` " >> /root/screen-log.txt
                bucket=`\aws s3 ls | grep "screen-record" | awk -F " " '{print $3}'`
                S3_PTH=`which s3cmd`
		$S3_PTH sync /root/screen-log.txt s3://$bucket/alerts/		
		if [ $? -eq 0 ]
                then
                        echo "SESSION_RECORD logs are being pushed to S3 `date +%F`" >/dev/null
                else
                        export SR_HL_CHK=2
                fi
        else
                export SR_HL_CHK=1
        fi
}
#Haystack shipper agent check
Filebeat_Log_Check()
{
        Log_Name=`ls -lt /var/log/session/*/*.log | head -1 | awk -F" " '{print $NF}'`
        grep "$Log_Name" /data/haystack-shipper/logs/filebeat 1>/dev/null
        if [ $? -ne '0' ]
        then
                export HS_AGT_Flag=2
        fi
}
Shipper_Agent_Check()
{
        /etc/init.d/haystack-shipper status | grep -i "pid" 2>/dev/null
        if [ $? -ne '0' ]
        then
                /etc/init.d/haystack-shipper restart 2>/dev/null
                /etc/init.d/haystack-shipper status |  grep -i "pid" 2>/dev/null
                if [ $? -ne '0' ]
                then
                        export HS_AGT_Flag=1
                else
                        Filebeat_Log_Check
                fi
        else
                Filebeat_Log_Check
        fi
}
Error_Alert()
{
	ERROR=`echo "Instance ID: $InstanceID ($IP) Account ID: $AccountID Account Name: $Accountname "`
        if [ $SR_HL_CHK -eq 1 ] && [ $HS_AGT_Flag -eq 1 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Screen recorder & Haystack agent are not running for below instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 2 ] && [ $HS_AGT_Flag -eq 1 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"S3 bucket push & Haystack agent are not running for below instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 1 ] && [ $HS_AGT_Flag -eq 2 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Screen recorder is not running & Session log files not populating in the dashboard for below instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 2 ] && [ $HS_AGT_Flag -eq 2 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"S3 bucket push is not running & Session log files not populating in the dashboard for below instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 0 ] && [ $HS_AGT_Flag -eq 1 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Screen recorder is running but shipper agent is not running for mention. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 0 ] && [ $HS_AGT_Flag -eq 2 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Screen recorder is running but Session log files not populating in the dashboard for mentioned instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 1 ] && [ $HS_AGT_Flag -eq 0 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Screen recorder is not running but Haystack shipper is running fine in the mentioned instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        elif [ $SR_HL_CHK -eq 2 ] && [ $HS_AGT_Flag -eq 0 ]
        then
                curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"S3 bucket push is not running but Haystack shipper is running fine for mentioned instance. `echo $ERROR` Please check\"}" https://hooks.slack.com/services/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
        else 
                echo "Both screen recorder & shipper agents are running fine" >> /root/screen-log.txt
        fi
}
InstanceID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
AccountID=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F'"' '/"accountId"/ { print $4 }'`
Accountname=`aws iam list-account-aliases --query 'AccountAliases[]' --output text`
SR_HL_CHK='0'
HS_AGT_Flag='0'
screen_record
Shipper_Agent_Check
Error_Alert
