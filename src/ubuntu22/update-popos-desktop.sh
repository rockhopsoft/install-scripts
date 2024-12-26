#!/bin/bash
set -x

echo '============================='
echo 'Updating PopOS (Ubuntu) 22.04'
echo '-----------------------------'

add-apt-repository universe
apt update
apt upgrade -y
apt autoremove
