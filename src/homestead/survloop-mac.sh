#!/bin/bash
set +x
echo '==============================='
echo 'Homestead Survloop Installation'
#echo '-------------------------------'
#echo 'To be run under "sudo su"'
if [ $# -eq 0 ]; then
    echo '-------------------------------'
    echo 'To run this with all commands printing to the screen,'
    echo 'cancel this (Ctrl+C), and re-run this script with any parameter:'
    echo '# bash ./install-scripts/homestead/survloop/survloop.sh debug'
fi
echo '==============================='
echo ''
read -p $'What is the directory for this local Survloop installation (relative to current folder)?\nIf it exists, it will be deleted for a fresh install.\n(e.g. survloop) \n' DIR
echo ''
read -p $'Do you want a standalone Survloop installation?\nIf not, you need a package which extends the Survloop engine.\n("y" or "n") \n' NOPCKG
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
echo '--'
echo '----'
echo '--------'
echo 'Survloop Installation Settings'
echo '------------------------------'
echo "New Directory: $DIR"
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
echo 'Install Homebrew Helpers'
echo '========================'
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
xcode-select --install
brew install perl
brew install php
brew services start php
brew link --force --overwrite php@7.4
echo ''
echo '--'
echo '----'
echo '--------'
echo 'Install Laravel Framework'
echo '========================='
if [ -d "$DIR" ]; then
    rm -R ./$DIR
fi
composer create-project laravel/laravel ./$DIR 8.0.* --no-dev
if [ -d "./$DIR/orig.env" ]; then
    rm -f ./$DIR/orig.env
fi
mv ./$DIR/.env ./$DIR/orig.env
cp ./install-scripts/homestead/samples/survloop.env $DIR/env.txt
if [ "$NOPCKG" == "n" ]; then
    perl -pi -w -e "s/APP_NAME=Survloop/APP_NAME=$PCKGCLASS/g" $DIR/env.txt
    perl -pi -w -e "s/survloop.local/$DIR.local/g" $DIR/env.txt
    perl -pi -w -e "s/DB_DATABASE=survloop/DB_DATABASE=$DIR/g" $DIR/env.txt
fi
mv ./$DIR/env.txt ./$DIR/.env
echo 'Laravel environment file updated.'
cd $DIR
php artisan key:generate
#php artisan cache:clear
composer require laravel/ui
php artisan ui vue --auth
echo ''
echo '--'
echo '----'
echo '--------'
if [ "$NOPCKG" == "n" ]; then
    echo 'Install Survloop & Extension Package'
    echo '===================================='
    composer require $PCKGVEND/$PCKGNAME
    cp -f ../install-scripts/samples/laravel-composer-package.json composer.json.txt
    SLPKG='rockhopsoft\/survlooporg'
    PCKGFULL="$PCKGVEND\/$PCKGNAME"
    perl -pi -w -e "s/$SLPKG/$PCKGFULL/g" composer.json.txt
    perl -pi -w -e "s/SurvloopOrg/$PCKGCLASS/g" composer.json.txt
    rm composer.json
    mv composer.json.txt composer.json
    mv config/app.php config/app.orig.php
    cp -f ../install-scripts/samples/laravel-config-app-package.php config/app.php
    perl -pi -w -e "s/SurvloopOrg/$PCKGCLASS/g" $DIR/config/app.php
    composer update
    php artisan optimize:clear
else
    echo 'Install Survloop'
    echo '================'
    composer require rockhopsoft/survloop
    rm composer.json
    cp -f ../install-scripts/samples/laravel-composer.json composer.json
    composer update
    php artisan optimize:clear
    mv config/app.php config/app.orig.php
    cp -f ../install-scripts/samples/laravel-config-app.php config/app.php
fi
composer dump-autoload
echo "0" | php artisan vendor:publish --force
php artisan optimize:clear
composer dump-autoload
DBKEY='\\Illuminate\\Support\\Facades\\DB'
perl -pi -w -e "s/$DBKEY::statement('SET SESSION sql_require_primary_key=0'); / /g" database/migrations/*.php
php artisan migrate --force
php artisan db:seed --force --class=SurvloopSeeder
php artisan db:seed --force --class=ZipCodeSeeder
php artisan db:seed --force --class=ZipCodeSeeder2
php artisan db:seed --force --class=ZipCodeSeeder3
php artisan db:seed --force --class=ZipCodeSeeder4
if [ "$NOPCKG" == "n" ]; then
    echo "yes" | php artisan db:seed --force --class=$PCKGCLASS
fi
#chown -R www-data:www-data storage bootstrap/cache resources/views database app/Models
php artisan optimize:clear
composer dump-autoload
curl http://$DIR.local/css-reload
