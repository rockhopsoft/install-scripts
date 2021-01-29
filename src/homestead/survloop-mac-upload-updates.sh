#!/bin/bash
set +x

install-scripts/src/survloop-mac-upload-updates.sh

echo '============================='
echo 'Install Updated Survloop Code'
echo '-----------------------------'
echo 'To be run under "sudo su"'
echo '--'
echo '----'
echo '--------'
echo 'Survloop Installation Settings'
echo '------------------------------'
echo "Domain:        $DIR"
echo "IP Address:    $IP"
echo "Username:      $SUPUSER"
if [ "$NOPCKG" == "n" ]; then
    echo "Package:       $PCKGVEND/$PCKGNAME"
    echo "Package Class: $PCKGCLASS"
fi
echo '=============================='



scp -P 843 /Volumes/_MoData/zCode/MediaTemple/wikiworldorder.org-zips/*.* wwouser@104.236.36.188:/home/wwouser/


