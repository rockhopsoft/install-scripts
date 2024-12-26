#!/bin/bash
set -x

# To be run under sudo su...

source create-super-user-cloudpanel.sh

echo '===================================='
echo 'Hardening CloudPanel on Ubuntu 22.04'
echo '------------------------------------'

read -p $'Was is the IP address for this server?\n(e.g. 321.654.987.210)\n' IP

echo ''
echo '=============='
echo 'Ubuntu Updates'
echo '--------------'
add-apt-repository universe
apt update
apt upgrade -y
apt remove unattended-upgrades -y

echo ''
echo '==========================='
echo 'Harden /etc/ssh/sshd_config'
echo '---------------------------'
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
systemctl restart ssh
#systemctl restart sshd

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
if systemctl is-active --quiet fail2ban; then
  echo "Fail2ban is running"
else
  echo "Fail2ban is not running"
fi
fail2ban-client status sshd

echo ''
echo '=============='
echo 'Install ClamAV'
echo '--------------'
echo 'https://documentation.wazuh.com/current/user-manual/capabilities/malware-detection/clam-av-logs-collection.html'
apt install clamav clamav-daemon -y
systemctl stop clamav-daemon
systemctl stop clamav-freshclam
freshclam
sed -i 's/LogSyslog false/LogSyslog true/g' /etc/clamav/clamd.conf
systemctl enable clamav-daemon
systemctl start clamav-daemon
if systemctl is-active --quiet clamav-daemon; then
  echo "ClamAV is running"
else
  echo "ClamAV is not running"
fi
clamscan --version
echo '-----------------------------------------'
echo 'ClamAV: Add this line to the crontab file'
echo '-----------------------------------------'
echo '0 2 * * * /usr/bin/clamscan -r / --remove --log=/var/log/clamav-scan.log'
echo '-----------------------------------------'
crontab -e


echo '================'
echo 'Install Suricata'
echo '----------------'
echo 'https://docs.suricata.io/en/latest/'
apt-get install software-properties-common
add-apt-repository ppa:oisf/suricata-stable
apt update
apt install suricata jq
suricata --build-info
#ip addr
#echo 'Use that IP info to configure Suricata?..'
#nano /etc/suricata/suricata.yaml
sed -i 's/filetype: regular #regular|syslog|unix_dgram|unix_stream|redis/filetype: unix_stream #regular|syslog|unix_dgram|unix_stream|redis/g' /etc/suricata/suricata.yaml
sed -i 's/filename: eve.json/filename: \/var\/log\/suricata\/eve.json/g' /etc/suricata/suricata.yaml
systemctl start suricata
systemctl enable suricata
if systemctl is-active --quiet suricata; then
  echo "Suricata is running"
else
  echo "Suricata is not running"
fi
echo '---'
echo 'https://documentation.wazuh.com/current/proof-of-concept-guide/integrate-network-ids-suricata.html'
echo '---'
sed -i 's/#HOME_NET: "any"/HOME_NET: "[$IP]"/g' /etc/suricata/suricata.yaml
sed -i 's/EXTERNAL_NET: "!$HOME_NET"/#EXTERNAL_NET: "!$HOME_NET"/g' /etc/suricata/suricata.yaml
sed -i 's/#EXTERNAL_NET: "any"/EXTERNAL_NET: "any"/g' /etc/suricata/suricata.yaml
sed -i 's/default-rule-path: \/var\/lib\/suricata\/rules/default-rule-path: \/etc\/suricata\/rules/g' /etc/suricata/suricata.yaml
sed -i 's/- suricata.rules/- "*.rules"/g' /etc/suricata/suricata.yaml
systemctl restart suricata


#echo '============'
#echo 'Install AIDE'
#echo '------------'
#echo "Y \n" | apt install aide
#aideinit
#cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
#cp /var/lib/aide/aide.conf.autogenerated /etc/aide/aide.conf

apt-get update
ufw status verbose