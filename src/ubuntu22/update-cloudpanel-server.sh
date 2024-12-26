#!/bin/bash
set -x

echo '( To be run under sudo su ... )'

echo '============='
echo 'Update Ubuntu'
echo '-------------'
add-apt-repository universe
apt update
apt upgrade -y
apt autoremove

apt-get update
apt update && apt dist-upgrade
apt install update-manager-core
do-release-upgrade


echo '================='
echo 'Update CloudPanel'
echo '-----------------'
clp-update


echo '============='
echo 'Update ClamAV'
echo '-------------'
systemctl stop clamav-daemon
systemctl stop clamav-freshclam
freshclam
systemctl enable clamav-daemon
systemctl start clamav-daemon
systemctl status clamav-daemon

echo '==============='
echo 'Update Suricata'
echo '---------------'
suricata-update
