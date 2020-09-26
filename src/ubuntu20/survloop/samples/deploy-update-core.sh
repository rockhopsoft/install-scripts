#!/bin/bash

echo 'Deploying Code from Staging Directory...'

set -x

DIR="$1"
SUPUSER="rocky"
PCKGA="rockhopsoft"
PCKGB="rockhopsoftcom"

set +x

echo 'Making Copies From Staging...'
cp -r /home/$SUPUSER/staging/rockhopsoft/survloop/src /tmp/staging/rockhopsoft/survloop
cp -r /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/src /tmp/staging/rockhopsoft/survloop-libraries
cp -r /home/$SUPUSER/staging/$PCKGA/$PCKGB/src /tmp/staging/$PCKGA/$PCKGB

set -x

rm -r /tmp/backup/rockhopsoft/survloop/src
mv /var/www/$DIR/vendor/rockhopsoft/survloop/src /tmp/backup/rockhopsoft/survloop
mv /tmp/staging/rockhopsoft/survloop/src /var/www/$DIR/vendor/rockhopsoft/survloop

rm -r /tmp/backup/rockhopsoft/survloop-libraries/src
mv /var/www/$DIR/vendor/rockhopsoft/survloop-libraries/src /tmp/backup/rockhopsoft/survloop-libraries
mv /tmp/staging/rockhopsoft/survloop-libraries/src /var/www/$DIR/vendor/rockhopsoft/survloop-libraries

rm -r /tmp/backup/$PCKGA/$PCKGB/src
mv /var/www/$DIR/vendor/$PCKGA/$PCKGB/src /tmp/backup/$PCKGA/$PCKGB
mv /tmp/staging/$PCKGA/$PCKGB/src /var/www/$DIR/vendor/$PCKGA/$PCKGB

set +x

echo 'Publish Updates and Clear Caches...'

if [ ! -f /var/swap.1 ]; then
    /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
    /sbin/mkswap /var/swap.1
    /sbin/swapon /var/swap.1
fi

set -x

cd /var/www/$DIR
php artisan optimize:clear
composer dump-autoload
echo "0" | php artisan vendor:publish --force

set +x

echo ''
echo '--'
echo '----'
echo '--------'
echo 'The Survloop Deployment Script Has Completed!'
echo '============================================='
echo '============================================='
echo ''
