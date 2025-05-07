#!/bin/bash
set +x
echo '====================='
echo 'Survloop Installation'
echo '---------------------'
SUPUSER="$USER"
echo ''
read -p $'What is the domain name for this Survloop installation?\n(e.g. example.com) \n' DIR
FULLDIR="/var/www/$DIR"
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
INSTALLDB="n"
#read -p $'Would you like to auto-install the Survloop database?\n("y" or "n") \n' INSTALLDB
#echo ''
echo '--'
echo '----'
echo '--------'
echo 'Survloop Installation Settings'
echo '------------------------------'
echo "Directory:        $DIR"
echo "Full Path:   $FULLDIR"
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
echo 'Install Laravel Framework'
echo '========================='

cd /var/www
rm -R $FULLDIR
composer create-project laravel/laravel $FULLDIR 11.* --no-dev
cd $FULLDIR
php artisan cache:clear
php /usr/local/bin/composer require laravel/fortify
php artisan vendor:publish --provider="Laravel\Fortify\FortifyServiceProvider"

composer require -W components/jquery components/jqueryui doctrine/dbal fortawesome/font-awesome guzzlehttp/guzzle intervention/image laravel/fortify laravel/helpers laravel/sanctum matthiasmullie/minify maatwebsite/excel mpdf/mpdf nnnick/chartjs paragonie/random_compat plotly/plotly.js predis/predis summernote/summernote twbs/bootstrap chargebee/chargebee-php spatie/laravel-csp symfony/mailgun-mailer symfony/http-client mailgun/mailgun-php php-http/guzzle7-adapter php-http/message
# composer require -W mews/captcha
# genealabs/laravel-model-caching
# no longer needed: fideloper/proxy
composer update

# For SSO with OpenID:
# php artisan install:api --passport
# php artisan passport:keys

mkdir packages && mkdir packages/rockhopsoft && mkdir packages/rockhopsoft/survloop && mkdir packages/rockhopsoft/survloop/src && mkdir packages/rockhopsoft/surv-data && mkdir packages/rockhopsoft/surv-data/src && mkdir packages/rockhopsoft/survloop-images && mkdir packages/rockhopsoft/survloop-images/src && mkdir packages/rockhopsoft/survloop-libraries && mkdir packages/rockhopsoft/survloop-libraries/src && mkdir packages/rockhopsoft/api-connect && mkdir packages/rockhopsoft/api-connect/src
mkdir public/css && mkdir public/fonts && mkdir public/js && mkdir public/pdf && mkdir storage/app/cache && mkdir storage/app/cache/css && mkdir storage/app/cache/js && mkdir storage/app/cache/html && mkdir storage/app/cache/php
chown -R www-data:www-data ./
find ./ -type d -exec chmod 755 {} \;
find ./ -type f -exec chmod 644 {} \;
sudo chmod -R 0775 storage bootstrap/cache resources/views database app/Models public/css public/fonts public/js public/pdf


# import Survloop packages

composer dump-autoload
php artisan vendor:publish --all --force
php artisan config:clear && php artisan route:clear && php artisan view:clear
composer dump-autoload

if [ "$INSTALLDB" == "y" ]; then
    echo ''
    echo '--'
    echo '----'
    echo '--------'
    echo 'Build Database with Laravel Migrations'
    echo '======================================'
    DBKEY='\\Illuminate\\Support\\Facades\\DB'
    sed -i "s/Schema::create/$DBKEY::statement('SET SESSION sql_require_primary_key=0'); Schema::create/g" /var/www/$DIR/database/migrations/*.php
    echo "yes" | php8.2 artisan migrate --force
    echo ''
    echo '--'
    echo '----'
    echo '--------'
    echo 'Fill Database with Laravel Seeders'
    echo '=================================='
    echo "yes" | php8.2 artisan db:seed --force --class=SurvloopSeeder
    echo "yes" | php8.2 artisan db:seed --force --class=ZipCodeSeeder
    echo "yes" | php8.2 artisan db:seed --force --class=ZipCodeSeeder2
    echo "yes" | php8.2 artisan db:seed --force --class=ZipCodeSeeder3
    echo "yes" | php8.2 artisan db:seed --force --class=ZipCodeSeeder4
    if [ "$NOPCKG" == "n" ]; then
        echo "yes" | php8.2 artisan db:seed --force --class=$PCKGCLASS
    fi
fi

chown -R www-data:www-data storage bootstrap/cache resources/views database app/Models public/css public/fonts public/js public/pdf
php artisan config:clear && php artisan route:clear && php artisan view:clear
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
