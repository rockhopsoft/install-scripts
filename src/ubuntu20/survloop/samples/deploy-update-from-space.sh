#!/bin/bash
set -x

DIR='survloop.org'
SUPUSER='survuser'
PCKGVEND='rockhopsoft'
PCKGNAME='survlooporg'

if [ $# -eq 1 ]; then
    DIR="$DIR-production"
fi

bash /home/$SUPUSER/survloop/deploy-update-dirs.sh

set +x 

if [ -d /home/$SUPUSER/staging/rockhopsoft/survloop/src ]; then
    rm -R /home/$SUPUSER/staging/rockhopsoft/survloop/src
fi
if [ -d /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/src ]; then
    rm -R /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/src
fi
if [ -d /home/$SUPUSER/staging/$PCKGVEND/$PCKGNAME/src ]; then
    rm -R /home/$SUPUSER/staging/$PCKGVEND/$PCKGNAME/src
fi

echo ''
echo 'Downloading from DigitalOcean Space...'
echo ''

set -x 

cd /home/$SUPUSER/staging/rockhopsoft/survloop
wget -c https://space.survloop.org/repos/survloop.tar.gz -O - | tar -xz --warning=none

cd /home/$SUPUSER/staging/rockhopsoft/survloop-libraries
wget -c https://space.survloop.org/repos/survloop-libraries.tar.gz -O - | tar -xz --warning=none

cd /home/$SUPUSER/staging/$PCKGVEND/$PCKGNAME
wget -c https://space.survloop.org/repos/$PCKGNAME.tar.gz -O - | tar -xz --warning=none

set +x 

bash /home/$SUPUSER/survloop/deploy-update-core.sh $DIR

cd /home/$SUPUSER/survloop
