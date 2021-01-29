#!/bin/bash
set -x

DOMAIN="$1"
IP="$2"
APPNAME="$3"

# To be run under sudo su...

# https://www.vultr.com/docs/install-jitsi-meet-on-ubuntu-20-04-lts

echo "Y" | apt-get install gnupg2 apt-transport-https nginx-full
apt-get update
apt-get upgrade

ufw allow OpenSSH
ufw allow http
ufw allow https
ufw allow in 10000:20000/udp
echo "y" | ufw enable

apt install -y openjdk-8-jre-headless
java -version
echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile
source /etc/profile

apt install -y nginx
systemctl start nginx.service
systemctl enable nginx.service

cd /tmp
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
echo "deb https://download.jitsi.org stable/"  | sudo tee -a /etc/apt/sources.list.d/jitsi-stable.list
apt update
apt install -y jitsi-meet

hostnamectl set-hostname $DOMAIN
echo "127.0.0.1 localhost $DOMAIN $IP" >> /etc/hosts
systemctl reload nginx

echo ''
echo '=================================='
echo ''
read -p $'Customize site logo PNG image URL:\n(press enter for none)\n' IMGLOGO
if [ -z "$IMGLOGO" ]
then
else
	wget $IMGLOGO
	cp $FILENAME /usr/share/jitsi-meet/images/watermark-custom.png
	sed -i "s/images\/watermark.svg/images\/watermark-custom.png/g" /usr/share/jitsi-meet/interface_config.js
	FILENAME="${IMGLOGO##*/}"

	read -p $'Customize site favicon image URL:\n(press enter for none)\n' FAVLOGO
	if [ -z "$FAVLOGO" ]
	then
	else
		FILENAME="${FAVLOGO##*/}"
		wget $IMGLOGO
		mv /usr/share/jitsi-meet/images/favicon.ico /usr/share/jitsi-meet/images/favicon-orig.ico
		cp $FILENAME /usr/share/jitsi-meet/images/favicon.ico

	fi
	sed -i "s/APP_NAME: 'Jitsi Meet'/APP_NAME: '$APPNAME'/g" /usr/share/jitsi-meet/interface_config.js
	sed -i "s/NATIVE_APP_NAME: 'Jitsi Meet'/NATIVE_APP_NAME: '$APPNAME'/g" /usr/share/jitsi-meet/interface_config.js
	sed -i "s/JITSI_WATERMARK_LINK: 'https:\/\/jitsi.org'/JITSI_WATERMARK_LINK: 'https:\/\/$DOMAIN'/g" /usr/share/jitsi-meet/interface_config.js

fi


echo ''
echo '=================================='
echo ''
read -p $'Do you want to install a Let\'s Encrypt SSL certificate now?\n(y or n)\n' SSL
if [ "$SSL" = "y" ]
then
	/usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
fi





