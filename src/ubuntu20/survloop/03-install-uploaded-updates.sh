#!/bin/bash
set +x

PCKGVEND="$1"
PCKGNAME="$2"
INSTDIR="$3"

echo '=============================='
echo "Install Updated Survloop Code: $PCKGNAME"
echo '------------------------------'
echo 'To be run under "sudo su"'
set -x

cd /home/$USER
rm -R src
tar -zxvf survloop.tar.gz
rm -R $INSTDIR/vendor/rockhopsoft/survloop/src
mv src $INSTDIR/vendor/rockhopsoft/survloop/src

tar -zxvf $PCKGNAME.tar.gz
rm -R $INSTDIR/vendor/$PCKGVEND/$PCKGNAME/src
mv src $INSTDIR/vendor/$PCKGVEND/$PCKGNAME/src

cd $INSTDIR
echo "yes" | composer dump-autoload
php artisan config:clear
php artisan route:clear
php artisan view:clear
echo "0" | php artisan vendor:publish --force
