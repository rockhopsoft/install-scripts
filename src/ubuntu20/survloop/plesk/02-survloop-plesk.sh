#!/bin/bash
set +x
echo '====================='
echo 'Survloop Installation'
echo '---------------------'
SUPUSER="$USER"
echo ''
read -p $'What is the domain name for this Survloop installation?\n(e.g. example.com) \n' DIR
FULLDIR="/var/www/vhosts/$DIR"
echo ''
read -p $'Do you want a standalone Survloop installation? If not, you need a package which extends the Survloop engine.\n("y" or "n") \n' NOPCKG
echo ''
PCKGVEND=""
PCKGNAME=""
PCKGCLASS=""
if [ "$NOPCKG" == "n" ]; then
    read -p $'What is the your package vendor name?\n(e.g. rockhopsoft) \n' PCKGVEND
    echo ''
    read -p $'What is the name of your package?\n(e.g. survlooporg) \n' PCKGNAME
    echo ''
    read -p $'What is the top-level class name for your package?\n(e.g. SurvloopOrg) \n' PCKGCLASS
    echo ''
fi
#read -p $'Would you like to auto-install the Survloop database?\n("y" or "n") \n' INSTALLDB
#echo ''
#read -p $'Would you like to install Matomo analytics on this server?\n("y" or "n") \n' INSTMATOMO
#echo ''
echo '--'
echo '----'
echo '--------'
echo 'Survloop Installation Settings'
echo '------------------------------'
echo "Domain:        $DIR"
echo "Domain Path:   $FULLDIR"
echo "Username:      $SUPUSER"
if [ "$NOPCKG" == "n" ]; then
    echo "Package:       $PCKGVEND/$PCKGNAME"
    echo "Package Class: $PCKGCLASS"
fi
echo '=============================='
if [ $# -eq 1 ]; then
    set -x
fi

echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Laravel'
echo '==============='

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Laravel Framework'
echo '========================='

sudo su


echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Pear, CURL, & Composer'
echo '=============================='

echo "Y" | apt-get install php-pear pkg-config php-xml php-cli php-dev php-sqlite3
wget http://pear.php.net/go-pear.phar
echo "Y" | apt-get install curl
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
echo "Y" | apt install zip unzip php-fpm php-mysql php-mbstring php-xml php-bcmath
echo "Y" | apt install php8.2-zip php8.2-gd ghostscript php8.2-cli php8.2-bcmath php8.2-common php8.2-dev php8.2-fpm php8.2-mbstring php8.2-mysql php8.2-opcache php8.2-readline php8.2-xml php8.2-zip php-redis
pecl install redis
#echo "\n extension = redis.io" >> /etc/php/8.0/fpm/php.ini




echo "Y" | apt-get install curl


cd $FULLDIR/httpdocs
rm -R laravel
/opt/plesk/php/8.2/bin/php /usr/lib/plesk-9.0/composer.phar create-project laravel/laravel laravel 11.* --no-dev
cd laravel
/opt/plesk/php/8.2/bin/php artisan cache:clear
/opt/plesk/php/8.2/bin/php /usr/lib/plesk-9.0/composer.phar require laravel/fortify
/opt/plesk/php/8.2/bin/php artisan vendor:publish --provider="Laravel\Fortify\FortifyServiceProvider"

#COMPOSER_MEMORY_LIMIT=-1 composer require rockhopsoft/survloop
/opt/plesk/php/8.2/bin/php /usr/lib/plesk-9.0/composer.phar require -W components/jquery components/jqueryui doctrine/dbal fortawesome/font-awesome guzzlehttp/guzzle intervention/image laravel/fortify laravel/helpers laravel/sanctum matthiasmullie/minify maatwebsite/excel mpdf/mpdf nnnick/chartjs paragonie/random_compat plotly/plotly.js predis/predis summernote/summernote twbs/bootstrap chargebee/chargebee-php spatie/laravel-csp
# mews/captcha
# genealabs/laravel-model-caching
# no longer needed: fideloper/proxy
/opt/plesk/php/8.2/bin/php /usr/lib/plesk-9.0/composer.phar update

mkdir packages && mkdir packages/rockhopsoft && mkdir packages/rockhopsoft/survloop && mkdir packages/rockhopsoft/survloop/src && mkdir packages/rockhopsoft/surv-data && mkdir packages/rockhopsoft/surv-data/src
mkdir packages/rockhopsoft/survloop-images && mkdir packages/rockhopsoft/survloop-images/src && mkdir packages/rockhopsoft/survloop-libraries && mkdir packages/rockhopsoft/survloop-libraries/src
mkdir public/css && mkdir public/fonts && mkdir public/js && mkdir public/pdf
mkdir storage/app/cache && mkdir storage/app/cache/css && mkdir storage/app/cache/js && mkdir storage/app/cache/html && mkdir storage/app/cache/php

#chown -R resourceinnovation.org:psacln ./
sudo find ./ -type f -exec chmod 644 {} \;
sudo find ./ -type d -exec chmod 755 {} \;
sudo chgrp -R psacln storage bootstrap/cache resources/views database app/Models public/css public/fonts public/js public/pdf
sudo chmod -R 0775 storage bootstrap/cache resources/views database app/Models public/css public/fonts public/js public/pdf

/opt/plesk/php/8.2/bin/php /usr/lib/plesk-9.0/composer.phar dump-autoload
/opt/plesk/php/8.2/bin/php artisan vendor:publish --all --force
/opt/plesk/php/8.2/bin/php artisan config:clear
/opt/plesk/php/8.2/bin/php artisan route:clear
/opt/plesk/php/8.2/bin/php artisan view:clear
/opt/plesk/php/8.2/bin/php /usr/lib/plesk-9.0/composer.phar dump-autoload
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Create Super User Deployment Tools'
echo '=================================='
mkdir /home/$SUPUSER/survloop/
cp /root/install-scripts/src/ubuntu20/survloop/samples/deploy-update-*.sh /home/$SUPUSER/survloop/

sed -i "s/DIR='survloop.org'/DIR='$DIR'/g" /home/$SUPUSER/survloop/*.sh
sed -i "s/SUPUSER='survuser'/SUPUSER='$SUPUSER'/g" /home/$SUPUSER/survloop/*.sh
sed -i "s/PCKGVEND='rockhopsoft'/PCKGVEND='$PCKGVEND'/g" /home/$SUPUSER/survloop/*.sh
sed -i "s/PCKGNAME='survlooporg'/PCKGNAME='$PCKGNAME'/g" /home/$SUPUSER/survloop/*.sh

cp /root/install-scripts/src/ubuntu20/survloop/samples/maintenance-mode.sh /home/$SUPUSER/survloop/maintenance-mode.sh
cp /root/install-scripts/src/ubuntu20/survloop/samples/maintenance-index.php /home/$SUPUSER/survloop/maintenance-index.php
mkdir /home/$SUPUSER/staging/
mkdir /home/$SUPUSER/staging/rockhopsoft
mkdir /home/$SUPUSER/staging/rockhopsoft/survloop
mkdir /home/$SUPUSER/staging/rockhopsoft/survloop-libraries
cp -R /var/www/$DIR/vendor/rockhopsoft/survloop/src /home/$SUPUSER/staging/rockhopsoft/survloop/src
cp -R /var/www/$DIR/vendor/rockhopsoft/survloop-libraries/src /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/src
if [ "$NOPCKG" == "n" ]; then
    mkdir /home/$SUPUSER/staging/$PCKGVEND
    mkdir /home/$SUPUSER/staging/$PCKGVEND/$PCKGNAME
    cp -R /var/www/$DIR/vendor/$PCKGVEND/$PCKGNAME/src /home/$SUPUSER/staging/$PCKGVEND/$PCKGNAME/src
fi
chown -R $SUPUSER:$SUPUSER /home/$SUPUSER/survloop
chown -R $SUPUSER:$SUPUSER /home/$SUPUSER/staging

if [ "$INSTALLDB" == "y" ]; then
    echo ''
    echo '--'
    echo '----'
    echo '--------'
    echo 'Build Database with Laravel Migrations'
    echo '======================================'
    DBKEY='\\Illuminate\\Support\\Facades\\DB'
    sed -i "s/Schema::create/$DBKEY::statement('SET SESSION sql_require_primary_key=0'); Schema::create/g" /var/www/$DIR/database/migrations/*.php
    echo "yes" | php artisan migrate --force
    echo ''
    echo '--'
    echo '----'
    echo '--------'
    echo 'Fill Database with Laravel Seeders'
    echo '=================================='
    echo "yes" | php artisan db:seed --force --class=SurvloopSeeder
    echo "yes" | php artisan db:seed --force --class=ZipCodeSeeder
    echo "yes" | php artisan db:seed --force --class=ZipCodeSeeder2
    echo "yes" | php artisan db:seed --force --class=ZipCodeSeeder3
    echo "yes" | php artisan db:seed --force --class=ZipCodeSeeder4
    if [ "$NOPCKG" == "n" ]; then
        echo "yes" | php artisan db:seed --force --class=$PCKGCLASS
    fi
fi

chown -R www-data:www-data storage bootstrap/cache resources/views database app/Models public/css public/fonts public/js public/pdf
php artisan config:clear
php artisan route:clear
php artisan view:clear
composer dump-autoload --optimize
curl https://$DIR/css-reload

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
