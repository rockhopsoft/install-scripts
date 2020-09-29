#!/bin/bash
set -x

DIR="survloop.org"
SUPUSER="survuser"
PCKGA="rockhopsoft"
PCKGB="survlooporg"

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
if [ -d /home/$SUPUSER/staging/$PCKGA/$PCKGB/src ]; then
    rm -R /home/$SUPUSER/staging/$PCKGA/$PCKGB/src
fi

if [ -f /home/$SUPUSER/staging/rockhopsoft/survloop/survloop.tar.gz ]; then
    rm -R /home/$SUPUSER/staging/rockhopsoft/survloop/src
fi
if [ -f /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/survloop-libraries.tar.gz ]; then
    rm -R /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/src
fi
if [ -f /home/$SUPUSER/staging/$PCKGA/$PCKGB/$PCKGB.tar.gz ]; then
    rm -R /home/$SUPUSER/staging/$PCKGA/$PCKGB/$PCKGB.tar.gz
fi

echo '--'
echo '----'
echo '----------'
echo '---------------------'
echo "In another terminal tab, browse to your local directory which stored tarred repository src folders. Then connect via SFTP and upload these:"
echo ""
echo "put survloop.tar.gz /home/$SUPUSER/staging/rockhopsoft/survloop/survloop.tar.gz"
echo ""
echo "put survloop-libraries.tar.gz /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/survloop-libraries.tar.gz"
echo ""
echo "put $PCKGB.tar.gz /home/$SUPUSER/staging/$PCKGA/$PCKGB/$PCKGB.tar.gz"
echo ""
echo ""
read -p $'Have you uploaded with SFTP?\n("y" or "n") \n' DONE

tar -C /home/$SUPUSER/staging/rockhopsoft/survloop/ -xz /home/$SUPUSER/staging/rockhopsoft/survloop/survloop.tar.gz --warning=none
tar -C /home/$SUPUSER/staging/rockhopsoft/survloop-libraries/ -xz /home/$SUPUSER/staging/rockhopsoft/survloop/survloop-libraries.tar.gz --warning=none
tar -C /home/$SUPUSER/staging/$PCKGA/$PCKGB/ -xz /home/$SUPUSER/staging/$PCKGA/$PCKGB/$PCKGB.tar.gz --warning=none

bash /home/$SUPUSER/survloop/deploy-update-core.sh $DIR

cd /home/$SUPUSER/survloop
