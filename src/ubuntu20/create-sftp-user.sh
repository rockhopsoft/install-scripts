#!/bin/bash
set +x
DEBUG=""
if [ $# -eq 1 ]
then
    DEBUG="y"
fi
echo '=================================='
echo 'Ubuntu 20.04 SFTP User Initiation'
echo '----------------------------------'
echo 'To be run on a DigitalOcean server, under sudo su.'
if [ $# -eq 0 ]
then
    echo '----------------------------------'
    echo 'To run this with all commands printing to the screen,'
    echo 'cancel this (Ctrl+C), and run this script with any parameter:'
    echo '# bash ./ubuntu20/survloop/01-create-user.sh debug'
fi
echo '=================================='
echo ''
read -p $'What user name should have SFTP access?\n(e.g. survftp)\n' USR
echo ''
read -p $'From which fixed IP address will you connect from for this server? This could be your super user\'s VPN or home router IP.\n(e.g. 123.456.789.012)\n' IP
echo ''
read -p $'Instead of 22, what SSH PORT will you connect to, between 23 and 1023?\n(e.g. 234)\n' PORT
echo ''
echo 'Ubuntu 20.04 Super User Initiation Settings'
echo '-------------------------------------------'
echo "User or VPN IP Address: $IP"
echo "Custom SSH Port:        $PORT"
echo "Suer User Name:         $USR"
echo "YubiKey Token:          $YUBI"
echo '==========================================='
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Creating New User Account'
echo '========================='
if [ "$DEBUG" = "y" ]
then
    set -x
fi

# https://www.digitalocean.com/community/tutorials/how-to-enable-sftp-without-shell-access-on-ubuntu-18-04
adduser $USR
rsync --archive --chown=$USR:$USR ~/.ssh /home/$USR
mkdir -p /var/sftp/$USR/uploads
chown root:root /var/sftp
chmod 755 /var/sftp
chown $USR:$USR /var/sftp/$USR/uploads

echo '' >> /etc/ssh/sshd_config
#echo 'Match Group sftp-only' >> /etc/ssh/sshd_config
echo 'Match User $USR' >> /etc/ssh/sshd_config
echo 'ForceCommand internal-sftp' >> /etc/ssh/sshd_config
echo 'ChrootDirectory /var/sftp' >> /etc/ssh/sshd_config
echo 'PermitTunnel no' >> /etc/ssh/sshd_config
echo 'AllowAgentForwarding no' >> /etc/ssh/sshd_config
echo 'AllowTcpForwarding no' >> /etc/ssh/sshd_config
echo 'X11Forwarding no' >> /etc/ssh/sshd_config
echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
echo 'AuthenticationMethods publickey' >> /etc/ssh/sshd_config
echo 'UsePAM no' >> /etc/ssh/sshd_config

systemctl restart sshd

echo ''
echo '--'
echo '----'
echo '--------'
echo '----------------'
echo 'Super User Initiation Complete'
echo '------------------------------'
echo 'Current Firewall Settings...'
ufw status verbose
echo 'You should now log out, '
echo 'and log back in as the super user.'
echo 'But to avoid getting locked out, '
echo 'first test this in another terminal tab:'
echo ''
echo "ssh $USR@<server_ip> -p $PORT"
echo ''
echo '==============================='
