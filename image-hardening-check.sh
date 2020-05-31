#!/bin/bash

touch /root/output.txt
touch /root/error.txt

> /root/output.txt
> /root/error.txt

    cat /etc/os-release | grep "VERSION_ID" | awk -F'=' '{print $2}' | tr -d '"' > os.txt
    O=`cat os.txt`
    A="2018.03"
    B="2"
    C="18.04"

    ### AMAZON LINUX 2 ###

    if [ $O == $B ]
    then


        linux2='/etc/default/grub:/etc/sysctl.conf:/etc/profile:/etc/init.d/functions:/etc/bashrc:/etc/csh.cshrc:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/modprobe.d/cramfs.conf:/etc/modprobe.d/hfs.conf:/etc/modprobe.d/hfsplus.conf:/etc/modprobe.d/squashfs.conf:/etc/modprobe.d/udf.conf:/etc/update-motd.d/30-banner:/etc/fstab:/etc/fstab:/etc/security/limits.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/fstab:/etc/profile:/etc/audit/auditd.conf:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/audit/rules.d/audit.rules:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/var/spool/cron/root:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/rsyslog.conf:/etc/ssh/sshd_config:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/ssh/sshd_config:/etc/modprobe.d/CIS.conf:/etc/ssh/sshd_config:/etc/fstab:/etc/fstab:/etc/fstab:/etc/fstab'

        STR_MTCH='GRUB_CMDLINE_LINUX="audit=1:net.ipv4.conf.all.send_redirects = 0:umask 027:umask 027:umask 027:umask 027:sfs.protected_hardlinks = 1:fs.protected_symlinks = 1:kernel.dmesg_restrict = 1:kernel.kptr_restrict = 2:install cramfs /bin/true:install hfs /bin/true:install hfsplus /bin/true:install squashfs /bin/true:install udf /bin/true:tput bold:/proc:/tmp:* hard core 0:fs.suid_dumpable = 0:net.ipv4.conf.default.send_redirects = 0:net.ipv4.conf.all.accept_redirects = 0:net.ipv4.conf.default.accept_redirects = 0:net.ipv6.conf.all.accept_redirects = 0:net.ipv6.conf.default.accept_redirects = 0:net.ipv4.conf.all.secure_redirects = 0:net.ipv4.conf.default.secure_redirects = 0:net.ipv4.conf.all.log_martians = 1:net.ipv4.conf.default.log_martians = 1:net.ipv6.conf.all.accept_ra = 0:net.ipv6.conf.default.accept_ra = 0:tmpfs:TMOUT=900:max_log_file_action = keep_logs:always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change:always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change:always,exit -F arch=b64 -S clock_settime -k time-change:always,exit -F arch=b32 -S clock_settime -k time-change:/etc/localtime -p wa -k time-change:always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale:always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale:/etc/issue -p wa -k system-locale:/etc/issue.net -p wa -k system-locale:/etc/hosts -p wa -k system-locale:/etc/sysconfig/network-scripts/ -p wa -k system-locale:/var/run/utmp -p wa -k session:/var/log/wtmp -p wa -k session:/var/log/btmp -p wa -k session:always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts:always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts:always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete:always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete:/etc/sudoers -p wa -k scope:/etc/sudoers.d -p wa -k scope:/var/log/sudo.log -p wa -k actions:/sbin/insmod -p x -k modules:/sbin/rmmod -p x -k modules:/sbin/modprobe -p x -k modules:/var/log/lastlog -p wa -k logins:/var/run/faillock/ -p wa -k logins:always,exit -F arch=b64 -S init_module -S delete_module -k modules:/etc/group -p wa -k identity:/etc/passwd -p wa -k identity:/etc/gshadow -p wa -k identity:/etc/shadow -p wa -k identity:/etc/security/opasswd -p wa -k identity:always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod:ClientAliveInterval 300:ClientAliveCountMax 0:Compression no:LogLevel VERBOSE:MaxAuthTries 2:MaxSessions 2:PermitRootLogin no:TCPKeepAlive no:X11Forwarding no:LoginGraceTime 1m:HostbasedAuthentication no:IgnoreRhosts yes:Protocol 2:MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com:Ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com:KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256:/usr/sbin/aide --check:kernel.randomize_va_space = 2:net.ipv4.ip_forward = 0:net.ipv4.conf.all.accept_source_route = 0:net.ipv4.conf.default.accept_source_route = 0:net.ipv4.icmp_echo_ignore_broadcasts = 1:net.ipv4.icmp_ignore_bogus_error_responses = 1:net.ipv4.conf.all.rp_filter = 1:net.ipv4.conf.default.rp_filter = 1:net.ipv4.tcp_syncookies = 1:$FileCreateMode 0640:Banner /etc/issue.net:install dccp /bin/true:install sctp /bin/true:install rds /bin/true:install tipc /bin/true:PermitUserEnvironment no:options ipv6 disable=1:PermitEmptyPasswords no:/home:/var/log:/var/log/audit:/var/tmp'

        Number=`echo "$linux2" | awk -F':' '{print NF}'`

        for (( c=1; c<=$Number; c++ ));
        do
            PTH=`echo $linux2 | cut -d':' -f$c`
            STR_MCH=`echo $STR_MTCH | cut -d':' -f$c`
            grep -v '#' $PTH | grep "$STR_MCH" >>/dev/null
            if [ "$?" -ne '0' ]
            then
                echo "$STR_MCH $PTH does not exist/incorrect" >> /root/error.txt
         fi
 done
    ### Misc commands - 1 ###

    grep -i "/bin/sh" /etc/update-motd.d/30-banner >>/dev/null
            if [ "$?" -ne '0' ]
            then
                echo "/bin/sh does not exist/incorrect in etc/update-motd.d/30-banner" >> /root/error.txt
         fi



     ### Misc commands - 2 ###

     rpm -qa | grep 'ntp\|aide' >>/dev/null
            if [ "$?" -ne '0' ]
            then
                echo "ntp or aide package does not exist" >> /root/error.txt
         fi


     ### Misc commands - 3 (file ownership) ###

      ls -lrth /boot/grub2/grub.cfg | awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm=`cat /root/output.txt`
           if [ "$Perm" != "root root" ]
            then
                echo "/boot/grub2/grub.cfg doesnt have root ownership" >> /root/error.txt
            fi



        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.d"| awk -F ' ' '{print $3,$4}' > /root/output.txt
    Perm1=`cat /root/output.txt`
           if [ "$Perm1" != "root root" ]
            then
                echo "/etc/cron.d doesnt have root ownership" >> /root/error.txt
            fi



        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.monthly"| awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm2=`cat /root/output.txt`
           if [ "$Perm2" != "root root" ]
            then
                echo "/etc/cron.monthly doesnt have root ownership" >> /root/error.txt
            fi


        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.weekly" | awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm3=`cat /root/output.txt`
           if [ "$Perm3" != "root root" ]
            then
                echo "/etc/cron.weekly doesnt have root ownership" >> /root/error.txt
            fi


        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.hourly" | awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm4=`cat /root/output.txt`
           if [ "$Perm4" != "root root" ]
            then
                echo "/etc/cron.hourly doesnt have root ownership" >> /root/error.txt
            fi


        ls -al /etc/ | grep -v "cron.daily\|cron.deny\|anacrontab" | grep -i "crontab" | awk -F ' ' '{print $3,$4}' > /root/output.txt
    Perm5=`cat /root/output.txt`
           if [ "$Perm5" != "root root" ]
            then
                echo "/etc/crontab doesnt have root ownership" >> /root/error.txt
            fi



     ### Misc commands - 4 ###






    ### AMAZON LINUX 2018.03 ###

    elif [ $O == $A ]
    then
        linux2018='/etc/ssh/sshd_config:/etc/update-motd.d/30-banner:/etc/fstab:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/modprobe.d/CIS.conf:/etc/sysconfig/init:/etc/fstab:/etc/yum.repos.d/amzn-nosrc.repo:/var/spool/cron/root:/etc/security/limits.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/profile:/etc/init.d/functions:/etc/bashrc:/etc/csh.cshrc:/etc/fstab:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/sysctl.conf:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/ssh/sshd_config:/etc/rsyslog.conf:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/audit.rules:/etc/audit/auditd.conf:/etc/ssh/sshd_config:/etc/fstab:/etc/fstab:/etc/fstab:/etc/fstab'


        STR_MTCH2='MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com:tput bold:proc:install cramfs /bin/true:install freevxfs /bin/true:install jffs2 /bin/true:install hfs /bin/true:install hfsplus /bin/true:install squashfs /bin/true:install udf /bin/true:install vfat /bin/true:options ipv6 disable=1:nstall dccp /bin/true:install sctp /bin/true:install rds /bin/true:install tipc /bin/true:PROMPT=no:tmpfs:gpgcheck=1:/usr/bin/aide --check:* hard core 0:fs.suid_dumpable = 0:net.ipv4.conf.all.send_redirects = 0:net.ipv4.conf.default.send_redirects = 0:net.ipv4.conf.all.secure_redirects = 0:net.ipv4.conf.default.secure_redirects = 0:net.ipv4.conf.all.log_martians = 1:net.ipv4.conf.default.log_martians = 1:net.ipv4.conf.all.rp_filter = 1:net.ipv4.conf.default.rp_filter = 1:net.ipv6.conf.all.accept_ra = 0:net.ipv6.conf.default.accept_ra = 0:net.ipv6.conf.all.accept_redirects = 0:net.ipv6.conf.default.accept_redirects = 0:umask 027:umask 027:umask 027:umask 027:proc:ClientAliveInterval 300:ClientAliveCountMax 0:Compression no:MaxAuthTries 2:MaxSessions 2:PermitRootLogin no:TCPKeepAlive no:X11Forwarding no:Banner /etc/issue.net:sfs.protected_hardlinks = 1:fs.protected_symlinks = 1:kernel.dmesg_restrict = 1:kernel.kptr_restrict = 2:LoginGraceTime 60:PermitEmptyPasswords no:IgnoreRhosts yes:LogLevel INFO:PermitUserEnvironment no:$FileCreateMode 0640:/var/log/sudo.log -p wa -k actions:always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete:always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete:always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts:always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts:always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access:always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod:always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod:/var/run/utmp -p wa -k session:/var/log/wtmp -p wa -k session:/var/log/btmp -p wa -k session:/var/log/lastlog -p wa -k logins:/var/run/faillock/ -p wa -k logins:/etc/selinux/ -p wa -k MAC-policy:always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale:always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale:/etc/issue -p wa -k system-locale:/etc/issue.net -p wa -k system-locale:/etc/hosts -p wa -k system-locale:/etc/sysconfig/network -p wa -k system-locale:/etc/group -p wa -k identity:/etc/passwd -p wa -k identity:/etc/gshadow -p wa -k identity:/etc/shadow -p wa -k identity:/etc/security/opasswd -p wa -k identity:always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change:always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change:always,exit -F arch=b64 -S clock_settime -k time-change:always,exit -F arch=b32 -S clock_settime -k time-change:/etc/localtime -p wa -k time-change:max_log_file_action = keep_logs:Protocol 2:/home:/var/log:/var/log/audit:/var/tmp'


        Number=`echo "$STR_MTCH2" | awk -F':' '{print NF}'`
        for (( c=1; c<=$Number; c++ ));
        do
            PTH2=`echo $linux2018 | cut -d':' -f$c`
            STR_MCH2=`echo $STR_MTCH2 | cut -d':' -f$c`
            grep -v '#' $PTH2 | grep "$STR_MCH2" >>/dev/null
            if [ "$?" -ne '0' ]
            then
                echo "$STR_MCH2 $PTH2 does not exist/incorrect" >> /root/error.txt
            fi
    done

    ### Misc commands -1 ###

     grep -i "/bin/sh" /etc/update-motd.d/30-banner >>/dev/null
            if [ "$?" -ne '0' ]
            then
                echo "/bin/sh does not exist/incorrect in etc/update-motd.d/30-banner" >> /root/error.txt
         fi


         ### Misc commands -2 ###

      rpm -qa | grep 'ntp\|aide' >>/dev/null
            if [ "$?" -ne '0' ]
            then
                echo "ntp or aide package does not exist" >> /root/error.txt
         fi  

         ### Misc commands -3 ###

        ls -lrth /boot/grub/menu.lst | awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm6=`cat /root/output.txt`
           if [ "$Perm6" != "root root" ]
            then
                echo "/boot/grub2/grub.cfg doesnt have root ownership" >> /root/error.txt
            fi




        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.d"| awk -F ' ' '{print $3,$4}' > /root/output.txt
    Perm7=`cat /root/output.txt`
           if [ "$Perm7" != "root root" ]
            then
                echo "/etc/cron.d doesnt have root ownership" >> /root/error.txt
            fi



        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.monthly"| awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm8=`cat /root/output.txt`
           if [ "$Perm8" != "root root" ]
            then
                echo "/etc/cron.monthly doesnt have root ownership" >> /root/error.txt
            fi


        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.weekly" | awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm9=`cat /root/output.txt`
           if [ "$Perm9" != "root root" ]
            then
                echo "/etc/cron.weekly doesnt have root ownership" >> /root/error.txt
            fi


        ls -al /etc/ | grep -v "cron.daily\|cron.deny" | grep -i "cron.hourly" | awk -F ' ' '{print $3,$4}' > /root/output.txt
        Perm10=`cat /root/output.txt`
           if [ "$Perm10" != "root root" ]
            then
                echo "/etc/cron.hourly doesnt have root ownership" >> /root/error.txt
            fi


        ls -al /etc/ | grep -v "cron.daily\|cron.deny\|anacrontab" | grep -i "crontab" | awk -F ' ' '{print $3,$4}' > /root/output.txt
    Perm11=`cat /root/output.txt`
           if [ "$Perm11" != "root root" ]
            then
                echo "/etc/crontab doesnt have root ownership" >> /root/error.txt
            fi

            ls -al /etc/ | grep -v "cron.deny" | grep -i "cron.daily" | awk -F ' ' '{print $3,$4}' > /root/output.txt
    Perm12=`cat /root/output.txt`
           if [ "$Perm12" != "root root" ]
            then
                echo "/etc/cron.daily doesnt have root ownership" >> /root/error.txt
            fi


            #elif [ $O == $C ]

                



    else
    ### Versions that does not use Golden AMI or using an Older Linux OS version ###

    echo " Ec2 instance is using an older Linux OS version which does not have a Golden AMI"  >> /root/error.txt
    fi

    ### OUTPUT ###

if [ -s /root/error.txt ]
then
    echo "Ec2 instance is not using an Hardened AMI - $(hostname -i|cut -d ' ' -f2)"
    echo "$(< /root/error.txt)"
    exit 2
else
    echo "Ec2 instance is using Hardened AMI - $(hostname -i|cut -d ' ' -f2)"
    exit 0
fi
