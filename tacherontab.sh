#!/bin/bash
# commande tacherontab
if [ $# -eq 3 -a "$1" = "-u" ]
then
USERNAME=$2
TYPE=$3
elif [ $# -eq 1 ]
then
TYPE=$1
USERNAME=`whoami`
else
echo "error pls check your nomber of arguments #tacherontab [-u user] {-l | -r | -e}"
exit 0
fi
case $TYPE in
"-l") if [ ! -f /etc/tacheron/tacherontab$USERNAME ]
        then
        echo "/etc/tacheron/tacherontab"$USERNAME" pas existe"
        else
        cat /etc/tacheron/tacherontab$USERNAME
        fi;;
"-r")   sudo rm /etc/tacheron/tacherontab$USERNAME;;
"-e")   if [ ! -d /etc/tacheron ]
        then
        echo "/etc/tacheron pas existe"
            mkdir /etc/tacheron
        else
            touch /tmp/tmpfichier$USERNAME
            hash=$(md5sum /tmp/tmpfichier$USERNAME | cut -d' ' -f1)
            vi /tmp/tmpfichier$USERNAME
            newhash=$(md5sum /tmp/tmpfichier$USERNAME | cut -d' ' -f1)
            if [ $hash != $newhash ]
                  then
                    sudo cp /tmp/tmpfichier$USERNAME /etc/tacheron/tacherontab$USERNAME
            fi
        fi;;
*) echo "error pls check your notation #tacherontab [-u user] {-l | -r | -e}" exit 0 ;;
esac
