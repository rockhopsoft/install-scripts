#!/bin/bash
set +x
DEBUG=""
if [ $# -eq 1 ]
then
    DEBUG="y"
fi
echo '================================================='
echo 'Ubuntu 22.04 Super User Initiation for CloudPanel'
echo '-------------------------------------------------'
echo 'To be run on a DigitalOcean server set up with root SSH Key authentication.'
if [ $# -eq 0 ]
then
    echo '-------------------------------------------------'
    echo 'To run this with all commands printing to the screen,'
    echo 'cancel this (Ctrl+C), and run this script with any parameter:'
    echo '# bash ./ubuntu20/survloop/01-create-user.sh debug'
fi
echo '================================================='
echo ''
read -p $'Instead of root, what super user name will manage this server?\n(e.g. survuser)\n' USR
echo ''
#read -p $'Do you want to require YubiKey authentication?\n("y" or "n")\n' WANTYUBI
#echo ''
YUBI=""
if [ "$WANTYUBI" = "y" ]
then
    read -p $'Please press the button on your YubiKey device:\n' YUBI
    YUBI=${YUBI:0:12}
fi
echo ''
echo 'Ubuntu 22.04 Super User Initiation Settings'
echo '-------------------------------------------'
echo "Super User Name:         $USR"
#echo "YubiKey Token:          $YUBI"
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
#apt-add-repository universe
#apt update
#sudo dpkg --configure -a
#echo "Y" | apt upgrade
adduser $USR
usermod -aG sudo $USR
rsync --archive --chown=$USR:$USR ~/.ssh /home/$USR
if [ -n "$YUBI" ]
then
    echo ''
    echo '--'
    echo '----'
    echo '--------'
    echo 'Install & Require YubiKey Authentication'
    echo '========================================'
    sudo apt-get install libpam-u2f
    mkdir -p ~/.config/Yubico
    pamu2fcfg > ~/.config/Yubico/u2f_keys
#    echo "$USR:$YUBI" >> /etc/yubico
#    sed -i 's/@include common-auth/auth required pam_yubico.so id=16 debug authfile=\/etc\/yubico/g' /etc/pam.d/sshd
#    sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
#    sed -i 's/# Authentication:/AuthenticationMethods publickey,keyboard-interactive/g' /etc/ssh/sshd_config
#    sed -i 's/UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config
else
#    sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
fi
#systemctl restart sshd
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Disable Root Login'
echo '====================================================='
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
systemctl restart sshd
#echo ''
#echo '--'
#echo '----'
#echo '--------'
#echo 'Disabling various over~networking'
#echo '================================='
#sed -i 's/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=1/g' /etc/sysctl.conf
#sed -i 's/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=1/g' /etc/sysctl.conf
#sed -i 's/#net.ipv4.conf.all.accept_redirects = 0/net.ipv4.conf.all.accept_redirects = 0/g' /etc/sysctl.conf
#sed -i 's/#net.ipv6.conf.all.accept_redirects = 0/net.ipv6.conf.all.accept_redirects = 0/g' /etc/sysctl.conf
#sed -i 's/#net.ipv4.conf.all.send_redirects = 0/net.ipv4.conf.all.send_redirects = 0/g' /etc/sysctl.conf
#sed -i 's/#net.ipv4.conf.all.accept_source_route = 0/net.ipv4.conf.all.accept_source_route = 0/g' /etc/sysctl.conf
#sed -i 's/#net.ipv6.conf.all.accept_source_route = 0/net.ipv6.conf.all.accept_source_route = 0/g' /etc/sysctl.conf
#sed -i 's/#net.ipv4.conf.all.log_martians = 1/net.ipv4.conf.all.log_martians = 1/g' /etc/sysctl.conf
#sysctl -p
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
echo "ssh $USR@<server_ip>"
echo ''
echo '==============================='
