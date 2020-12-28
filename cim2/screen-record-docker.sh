/bin/echo '
if [ "x$SESSION_RECORD" = "x" ]
then
timestamp=$(date +%d-%m-%Y-%T)
if [ ! -d /home/$USER/session ]; then
mkdir /home/$USER/session
chmod +x /home/$USER/session
chmod 755 /home/$USER/session
fi
if [ ! -d /home/$USER/session/$USER ]; then
mkdir /home/$USER/session/$USER
else
echo "Recording $USER session"
fi
session_log=/home/$USER/session/$USER/session.$USER.$$.$timestamp.log
SESSION_RECORD=started
export SESSION_RECORD
script -t -f -q 2>${session_log}.timing $session_log
exit
fi' >> /etc/profile
