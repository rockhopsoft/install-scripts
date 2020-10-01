#!/bin/bash
set -x

DIR='survloop.org'

if [ $# -eq 1 ]; then
    DIR="$DIR-production"
fi

bash /home/$SUPUSER/survloop/deploy-update-dirs.sh
bash /home/$SUPUSER/survloop/deploy-update-core.sh $DIR

cd /home/$SUPUSER/survloop
