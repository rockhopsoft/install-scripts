#!/bin/bash
set -x

# To be run under sudo su...

# https://www.vultr.com/docs/install-jitsi-meet-on-ubuntu-20-04-lts




echo ''
echo '=================================='
echo ''
read -p $'Do you want to install a Let\'s Encrypt SSL certificate now?\n(y or n)\n' SSL
if [ "$SSL" = "y" ]
then
    /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
fi


