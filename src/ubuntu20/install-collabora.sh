#!/bin/bash
set +x

DOMAINCOLLAB="collabora.rockhopsoft.com"
DOMAIN="cloud\\.rockhopsoft\\.com"
PASS="7tbP7iY7q77GA090"

echo '======================'
echo 'Collabora Installation'
echo '----------------------'
echo 'To be run under "sudo su"'
echo ''
read -p $'What is the domain name of this Collabora server?\n(e.g. collabora.rockhopsoft.com) \n' DOMAINCOLLAB
echo ''
read -p $'What is the domain name of the Nextcloud server?\n(e.g. cloud\\.rockhopsoft\\.com) \n' DOMAIN
echo ''
read -p $'What is the new admin password for Collabora? \n' PASS
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install NGINX'
echo '============='
apt update
echo "Y" | apt install nginx
ufw allow 'Nginx HTTP'
ufw allow 'Nginx HTTPS'
echo "y" | ufw enable

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
echo "Y" | apt install zip unzip php-fpm php-mysql php-mbstring php-xml php-bcmath 
echo "Y" | apt install php8.0-zip php8.0-gd ghostscript php8.0-cli php8.0-bcmath 
echo "Y" | apt install php8.0-common php8.0-dev php8.0-fpm php8.0-mbstring
echo "Y" | apt install php8.0-mysql php8.0-opcache php8.0-readline php8.0-xml php8.0-zip php-redis
systemctl reload nginx
systemctl start php8.0-fpm
systemctl enable php8.0-fpm
systemctl reload nginx

cp install-collabora-nginx.conf /etc/nginx/sites-available/$DOMAINCOLLAB
sed -i "s/server_name _/server_name $DOMAINCOLLAB/g" /etc/nginx/sites-available/$DOMAINCOLLAB
ln -s /etc/nginx/sites-available/$DOMAINCOLLAB /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default
systemctl reload nginx


apt install mariadb-server mariadb-client
mysql_secure_installation





snap install --classic certbot
certbot --nginx



apt install docker.io
docker pull collabora/code
docker run -t -d -p 127.0.0.1:9980:9980 -e "domain=$DOMAIN" -e "username=admin" -e "password=$PASS" --restart always collabora/code

# docker run -t -d -p 127.0.0.1:9980:9980 -e "domain=cloud\\.rockhopsoft\\.com" -e "server_name=cloud\\.rockhopsoft\\.com" -e "cert_domain=collabora\\.rockhopsoft\\.com" -e "username=admin" -e "password=7tbP7iY7q77GA090" --restart always collabora/code


# docker run -t -d -p 127.0.0.1:9980:9980 -e 'domain=cloud\\.rockhopsoft\\.com' -e "extra_params=--o:ssl.enable=false --o:ssl.termination=true" --restart always collabora/code

