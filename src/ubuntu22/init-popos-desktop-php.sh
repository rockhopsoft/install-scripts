#!/bin/bash
set -x

echo '====================================================='
echo 'Prepping PopOS (Ubuntu) 22.04 for Laravel Development'
echo '-----------------------------------------------------'

echo ''
add-apt-repository ppa:ondrej/php
apt update && apt upgrade -y
apt install -y apache2 php8.3 php8.3-cli php8.3-mbstring php8.3-xml php8.3-bcmath php8.3-curl php8.3-tokenizer php8.3-zip php8.3-common php8.3-mysql php8.3-gd php-sqlite3 ghostscript unzip curl composer git
update-alternatives --set php /usr/bin/php8.3
php -v

cd /var/www

echo ''
echo '======================='
echo 'Install Pear & Composer'
echo '-----------------------'
wget http://pear.php.net/go-pear.phar
php go-pear.phar
echo "Y" | apt-get install curl
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
#HASH=`curl -sS https://composer.github.io/installer.sig`
#php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo ''
echo '============='
echo 'Install MYSQL'
echo '-------------'
apt install -y mysql-server
mysql_secure_installation
echo 'SET MYSQL ROOT PASSWORD:'
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'strong_password';"
echo 'FLUSH PRIVILEGES;'
mysql -u root

systemctl stop mysql
systemctl start mysql

#apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
#echo 'Alias /phpmyadmin /usr/share/phpmyadmin'
#nano /etc/apache2/conf-available/phpmyadmin.conf
#a2ensite phpmyadmin
#systemctl restart apache2

echo ''
echo '==================='
echo 'Setup Apache Config'
echo '-------------------'
a2dissite 000-default.conf
echo 'NOW RUN: ls /etc/apache2/sites-available'
echo 'And copy a default to map to local install.'
echo 'THEN RUN: a2ensite mysite.local.conf'
echo 'THEN RUN: a2enmod rewrite'
echo 'THEN RUN: systemctl restart apache2'
echo ''

nano /etc/hosts

