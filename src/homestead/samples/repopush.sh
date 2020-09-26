#!/bin/bash
set -x

DIR="survloop"

rm -r ./homestead/code/$DIR/vendor/rockhopsoft/survloop/src
cp -r ./repos/survloop/src ./homestead/code/survloop/vendor/rockhopsoft/survloop/

rm -r ./homestead/code/$DIR/vendor/rockhopsoft/survloop-libraries/src
cp -r ./repos/survloop-libraries/src ./homestead/code/survloop/vendor/rockhopsoft/survloop-libraries/

rm -r ./homestead/code/$DIR/app/Models/*

cd ./homestead/code/survloop/
echo "0" | php artisan vendor:publish --force
