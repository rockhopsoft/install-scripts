#!/bin/bash
set -x

# Directory where all your repositories are located:
REPODIR="~/repos"

# Directory which syncs with the virtual server
HOMEDIR="~/homestead/code"

# Installation sub-directory within synched virtual server
INSTDIR="survloop"

rm -r $HOMEDIR/$INSTDIR/vendor/rockhopsoft/survloop/src
cp -r $REPODIR/survloop/src $HOMEDIR/$INSTDIR/vendor/rockhopsoft/survloop/

rm -r $HOMEDIR/$INSTDIR/vendor/rockhopsoft/survloop-libraries/src
cp -r $REPODIR/survloop-libraries/src $HOMEDIR/$INSTDIR/vendor/rockhopsoft/survloop-libraries/

rm -r $HOMEDIR/$INSTDIR/app/Models/*

cd $HOMEDIR/$INSTDIR/
composer dump-autoload
echo "0" | php artisan vendor:publish --force
php artisan optimize:clear
curl http://$INSTDIR.local/css-reload
