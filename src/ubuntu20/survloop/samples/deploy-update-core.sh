#!/bin/bash

echo 'Deploying Code from Staging Directory...'

set -x

DIR="$1"
SUPUSER='survuser'
PCKGVEND='rockhopsoft'
PCKGNAME='survlooporg'

set +x

echo 'Making Copies From Staging...'
cp -r /home/$SUPUSER/staging/rockhopsoft/survloop/src /tmp/staging/rockhopsoft/survloop
cp -r /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/src /tmp/staging/rockhopsoft/survloop-libraries
cp -r /home/$SUPUSER/staging/$PCKGVEND/$PCKGNAME/src /tmp/staging/$PCKGVEND/$PCKGNAME

set -x

rm -r /tmp/backup/rockhopsoft/survloop/src
mv /var/www/$DIR/vendor/rockhopsoft/survloop/src /tmp/backup/rockhopsoft/survloop
mv /tmp/staging/rockhopsoft/survloop/src /var/www/$DIR/vendor/rockhopsoft/survloop

rm -r /tmp/backup/rockhopsoft/survloop-libraries/src
mv /var/www/$DIR/vendor/rockhopsoft/survloop-libraries/src /tmp/backup/rockhopsoft/survloop-libraries
mv /tmp/staging/rockhopsoft/survloop-libraries/src /var/www/$DIR/vendor/rockhopsoft/survloop-libraries

rm -r /tmp/backup/$PCKGVEND/$PCKGNAME/src
mv /var/www/$DIR/vendor/$PCKGVEND/$PCKGNAME/src /tmp/backup/$PCKGVEND/$PCKGNAME
mv /tmp/staging/$PCKGVEND/$PCKGNAME/src /var/www/$DIR/vendor/$PCKGVEND/$PCKGNAME

set +x

echo 'Publish Updates and Clear Caches...'

if [ ! -f /var/swap.1 ]; then
    /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
    /sbin/mkswap /var/swap.1
    /sbin/swapon /var/swap.1
fi

set -x

cd /var/www/$DIR
composer dump-autoload
echo "0" | php artisan vendor:publish --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
curl http://$DIR/css-reload

set +x

echo ''
echo '--'
echo '----'
echo '--------'
echo 'The Survloop Deployment Script Has Completed!'
echo '============================================='
echo '============================================='
echo ''
