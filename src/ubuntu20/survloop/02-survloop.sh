#!/bin/bash
set +x
echo '====================='
echo 'Survloop Installation'
echo '---------------------'
echo 'To be run under "sudo su"'
if [ $# -eq 0 ]
then
    echo '---------------------'
    echo 'To run this with all commands printing to the screen,'
    echo 'cancel this (Ctrl+C), and re-run this script with any parameter:'
    echo '# bash /root/ubuntu20/survloop/02-survloop.sh debug'
fi
echo '====================='
echo ''
read -p $'Which super username will deploy updates on this server?\n(e.g. survuser) \n' USR
echo ''
read -p $'What is the domain name for this Survloop installation?\n(e.g. example.com) \n' DIR
echo ''
read -p $'What is the IP address for this server?\n(e.g. 123.456.789.012) \n' IP
echo ''
read -p $'Would you like to install an SSL certificate using EFF\'s Certbot?\n("y" or "n") \n' SSLCERT
echo ''
read -p $'Do you want a standalone Survloop installation? If not, you must have a package which extends the Survloop engine.\n("y" or "n") \n' NOPCKG
echo ''
PCKGUSER=""
PCKGNAME=""
PCKGCLASS=""
if [ "$NOPCKG" == "n" ]
then
    read -p $'What is the username/owner of your package?\n(e.g. rockhopsoft) \n' PCKGUSER
    echo ''
    read -p $'What is the name of your package?\n(e.g. survlooporg) \n' PCKGNAME
    echo ''
    read -p $'What is the top-level class name for your package?\n(e.g. SurvloopOrg) \n' PCKGCLASS
    echo ''
fi
echo '--'
echo '----'
echo '--------'
echo 'Survloop Installation Settings'
echo '------------------------------'
echo "Domain:        $DIR"
echo "IP Address:    $IP"
echo "Username:      $USR"
if [ "$NOPCKG" == "n" ]
then
    echo "Package:       $PCKGUSER/$PCKGNAME"
    echo "Package Class: $PCKGCLASS"
fi
echo "Install SSL?   $SSLCERT"
echo '=============================='
if [ $# -eq 1 ]
then
    set -x
fi
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
echo "Y" | apt install zip unzip php-fpm php-mysql php-mbstring php-xml php-bcmath php7.4-zip php7.4-gd ghostscript
systemctl reload nginx
cp /root/ubuntu20/survloop/samples/nginx-example.com /etc/nginx/sites-available/$DIR
sed -i "s/example.com/$DIR/g" /etc/nginx/sites-available/$DIR
sed -i "s/server.ip.address/$IP/g" /etc/nginx/sites-available/$DIR
#nano /etc/nginx/sites-available/$DIR
ln -s /etc/nginx/sites-available/$DIR /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx
if [ "$SSLCERT" == "y" ]
then
    echo ''
    echo '--'
    echo '----'
    echo '--------'
    echo "Install SSL Certificate with EFF's CertBot"
    echo '=========================================='
    apt-get update
    snap install --classic certbot
    certbot --nginx
    ufw allow 'Nginx Full'
    echo "y" | ufw delete allow 'Nginx HTTP'
    echo "y" | nginx -t
    echo "y" | systemctl reload nginx
    ufw status verbose
fi
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Pear, CURL, & Composer'
echo '=============================='
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1
echo "Y" | apt-get install php-pear pkg-config php-xml php7.4-xml php7.4-cli php-dev
wget http://pear.php.net/go-pear.phar
echo ''
echo '--- For Survloop Installations, ---'
echo '--- press ENTER below for       ---'
echo '--- all 12 PEAR defaults.       ---'
echo ''
php go-pear.phar
echo "Y" | apt-get install curl
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Laravel Framework'
echo '========================='
if [ -d "/var/www/$DIR" ]
then
    rm -R /var/www/$DIR
fi
composer create-project laravel/laravel /var/www/$DIR 8.0.*
chown -R $USR:$USR /var/www/$DIR
cd /var/www/$DIR
php artisan key:generate
chown -R www-data:www-data storage bootstrap/cache resources/views database app/Models
php artisan cache:clear
composer require laravel/ui
php artisan ui vue --auth
systemctl reload nginx
ufw status verbose
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Enter Laravel Database Login Info'
echo '================================='
if [ "$NOPCKG" == "n" ]
then
    sed -i "s/APP_NAME=Laravel/APP_NAME=$PCKGCLASS/g" /var/www/$DIR/.env
else
    sed -i "s/APP_NAME=Laravel/APP_NAME=Survloop/g" /var/www/$DIR/.env
fi
sed -i "s/APP_ENV=local/APP_ENV=production/g" /var/www/$DIR/.env
sed -i "s/APP_DEBUG=true/APP_DEBUG=false/g" /var/www/$DIR/.env
URLLOCAL="http:\/\/localhost"
URLSERVR="https:\/\/$DIR"
sed -i "s/APP_URL=$URLLOCAL/APP_URL=$URLSERVR/g" /var/www/$DIR/.env
nano /var/www/$DIR/.env
echo 'Laravel environment file updated.'
echo ''
echo '--'
echo '----'
echo '--------'
if [ "$NOPCKG" == "n" ]
then
    echo 'Install Survloop & Extension Package'
    echo '===================================='
else
    echo 'Install Survloop'
    echo '================'
fi    
php artisan config:cache
if [ "$NOPCKG" == "n" ]
then
    cp -f /root/ubuntu20/survloop/samples/laravel-composer-package.json /var/www/$DIR/composer.json
    SLPKG='rockhopsoft\/survlooporg'
    PCKGFULL="$PCKGUSER\/$PCKGNAME"
    sed -i "s/$SLPKG/$PCKGFULL/g" /var/www/$DIR/composer.json
    sed -i "s/SurvloopOrg/$PCKGCLASS/g" /var/www/$DIR/composer.json
    cp -f /root/ubuntu20/survloop/samples/laravel-config-app-package.php /var/www/$DIR/config/app.php
    sed -i "s/SurvloopOrg/$PCKGCLASS/g" /var/www/$DIR/config/app.php
else
    cp -f /root/ubuntu20/survloop/samples/laravel-composer.json /var/www/$DIR/composer.json
    cp -f /root/ubuntu20/survloop/samples/laravel-config-app.php /var/www/$DIR/config/app.php
fi
composer install --optimize-autoloader --no-dev
php artisan optimize:clear
composer dump-autoload
echo "0" | php artisan vendor:publish --force
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Create Super User Deployment Tools'
echo '=================================='
mkdir /home/$USR/survloop/
cp /root/ubuntu20/survloop/samples/deploy-update-from-staging.sh /home/$USR/survloop/deploy-update-from-staging.sh
cp /root/ubuntu20/survloop/samples/maintenance-mode.sh /home/$USR/survloop/maintenance-mode.sh
cp /root/ubuntu20/survloop/samples/maintenance-index.php /home/$USR/survloop/maintenance-index.php
mkdir /home/$USR/staging/
mkdir /home/$USR/staging/rockhopsoft
mkdir /home/$USR/staging/rockhopsoft/survloop
mkdir /home/$USR/staging/rockhopsoft/survloop-libraries
cp -R /var/www/$DIR/vendor/rockhopsoft/survloop/src /home/$USR/staging/rockhopsoft/survloop/src
cp -R /var/www/$DIR/vendor/rockhopsoft/survloop-libraries/src /home/$USR/staging/rockhopsoft/survloop-libraries/src
if [ "$NOPCKG" == "n" ]
then
    mkdir /home/$USR/staging/$PCKGUSER
    mkdir /home/$USR/staging/$PCKGUSER/$PCKGNAME
    cp -R /var/www/$DIR/vendor/$PCKGUSER/$PCKGNAME/src /home/$USR/staging/$PCKGUSER/$PCKGNAME/src
fi
chown -R $USR:$USR /home/$USR/survloop
chown -R $USR:$USR /home/$USR/staging
echo ''
echo '--'
echo '----'
echo '--------'
echo "Build Database with Laravel Migrations"
echo "======================================"
FACADE='\\Illuminate\\Support\\Facades\\DB'
sed -i "s/Schema::create/$FACADE::statement('SET SESSION sql_require_primary_key=0'); Schema::create/g" /var/www/$DIR/database/migrations/2014_10_12_100000_create_password_resets_table.php
sed -i "s/Schema::create/$FACADE::statement('SET SESSION sql_require_primary_key=0'); Schema::create/g" /var/www/$DIR/database/migrations/2019_08_19_000000_create_failed_jobs_table.php
echo "yes" | php artisan migrate --force
echo ''
echo '--'
echo '----'
echo '--------'
echo "Fill Database with Laravel Seeders"
echo "=================================="
echo "yes" | php artisan db:seed --force --class=SurvloopSeeder
echo "yes" | php artisan db:seed --force --class=ZipCodeSeeder
if [ "$NOPCKG" == "n" ]
then
    echo "yes" | php artisan db:seed --force --class=$PCKGCLASS
fi
chown -R www-data:www-data storage bootstrap/cache resources/views database app/Models
php artisan optimize:clear
composer dump-autoload --optimize
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Advanced Intrusion Detection Environment (AIDE)'
echo '======================================================='
echo "Y \n" | apt install aide
aideinit
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
cp /var/lib/aide/aide.conf.autogenerated /etc/aide/aide.conf
echo ''
echo '--'
echo '----'
echo '--------'
echo '----------------'
echo 'Survloop Installation Complete!'
echo '==============================='
echo 'Current Firewall Settings...'
ufw status verbose
set +x
echo 'Now rebooting...'
echo 'You should be able to log back in, and '
echo 'browse to the IP address of this server.'
echo '==============================='
set -x
reboot
