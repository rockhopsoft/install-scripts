#!/bin/bash
# Check deployment directories...
set +x

SUPUSER="rocky"
PCKGA="rockhopsoft"
PCKGB="rockhopsoftcom"

if [ ! -d /home/$SUPUSER/staging ]; then
    mkdir /home/$SUPUSER/staging
fi
if [ ! -d /home/$SUPUSER/staging/rockhopsoft ]; then
    mkdir /home/$SUPUSER/staging/rockhopsoft
fi
if [ ! -d /home/$SUPUSER/staging/rockhopsoft/survloop ]; then
    mkdir /home/$SUPUSER/staging/rockhopsoft/survloop
fi
if [ ! -d /home/$SUPUSER/staging/rockhopsoft/survloop-libraries ]; then
    mkdir /home/$SUPUSER/staging/rockhopsoft/survloop-libraries
fi
if [ ! -d /home/$SUPUSER/staging/$PCKGA/$PCKGB ]; then
    mkdir /home/$SUPUSER/staging/$PCKGA/$PCKGB
fi
chown -R $SUPUSER:$SUPUSER /home/$SUPUSER/staging

if [ ! -d /tmp/backup ]; then
    mkdir /tmp/backup
fi
if [ ! -d /tmp/backup/rockhopsoft ]; then
    mkdir /tmp/backup/rockhopsoft
fi
if [ ! -d /tmp/backup/rockhopsoft/survloop ]; then
    mkdir /tmp/backup/rockhopsoft/survloop
fi
if [ ! -d /tmp/backup/rockhopsoft/survloop-libraries ]; then
    mkdir /tmp/backup/rockhopsoft/survloop-libraries
fi
if [ ! -d /tmp/backup/$PCKGA/$PCKGB ]; then
    mkdir /tmp/backup/$PCKGA/$PCKGB
fi

if [ ! -d /tmp/staging ]; then
    mkdir /tmp/staging
fi
if [ ! -d /tmp/staging/rockhopsoft ]; then
    mkdir /tmp/staging/rockhopsoft
fi
if [ ! -d /tmp/staging/rockhopsoft/survloop ]; then
    mkdir /tmp/staging/rockhopsoft/survloop
fi
if [ ! -d /tmp/staging/rockhopsoft/survloop-libraries ]; then
    mkdir /tmp/staging/rockhopsoft/survloop-libraries
fi
if [ ! -d /tmp/staging/$PCKGA/$PCKGB ]; then
    mkdir /tmp/staging/$PCKGA/$PCKGB
fi
