#!/bin/bash
set -x

echo '=============================='
echo 'Hardening PopOS (Ubuntu) 22.04'
echo '------------------------------'

echo ''
echo '=============='
echo 'Ubuntu Updates'
echo '--------------'
add-apt-repository universe
apt update
apt upgrade -y
apt remove unattended-upgrades -y

echo ''
echo '======================='
echo 'Harden /etc/sysctl.conf'
echo '-----------------------'
sed -i 's/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv4.conf.all.accept_redirects = 0/net.ipv4.conf.all.accept_redirects = 0/g' /etc/sysctl.conf
sed -i 's/#net.ipv4.conf.all.send_redirects = 0/net.ipv4.conf.all.send_redirects = 0/g' /etc/sysctl.conf
sed -i 's/#net.ipv4.conf.all.log_martians = 1/net.ipv4.conf.all.log_martians = 1/g' /etc/sysctl.conf

echo ''
echo '======================================='
echo 'Disable IPv6 (Lower Security Footprint)'
echo '---------------------------------------'
echo "" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf
sysctl -p

echo ''
echo '================'
echo 'Install Fail2Ban'
echo '----------------'
echo "Y" | apt install fail2ban
systemctl start fail2ban
systemctl enable fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/#ignoreip = 127.0.0.1\/8 ::1/ignoreip = $IP/g" /etc/fail2ban/jail.local
sed -i 's/bantime  = 10m/bantime  = 30m/g' /etc/fail2ban/jail.local
sed -i 's/maxretry = 5/maxretry = 3/g' /etc/fail2ban/jail.local
sed -i 's/enabled = false/enabled = true/g' /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl status fail2ban.service
fail2ban-client status sshd

echo ''
echo '=============='
echo 'Install ClamAV'
echo '--------------'
apt install clamav clamav-daemon -y
systemctl stop clamav-daemon
systemctl stop clamav-freshclam
freshclam
systemctl enable clamav-daemon
systemctl start clamav-daemon
systemctl status clamav-daemon
clamscan --version

echo '-----------------------------------------'
echo 'ClamAV: Add this line to the crontab file'
echo '-----------------------------------------'
echo '0 2 * * * /usr/bin/clamscan -r / --remove --log=/var/log/clamav-scan.log'
echo '-----------------------------------------'
crontab -e
