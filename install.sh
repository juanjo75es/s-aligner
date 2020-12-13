#!/bin/bash

if [ $(id -u) = 0 ]; then
    echo "Do not run as root, yet. Try again."
    exit 1
fi

req=`python3 -c 'import sys; print("%i" % (sys.hexversion<0x03000000))'`
if [ $req -eq 0 ]; then
    echo 'python version is >= 3'
    echo 'Installing dependices'
    sudo apt-get install python3-pip
    sudo apt-get update
else 
    echo "python version is < 3"
    echo "Installing Python3+ and dependencies" 
    sudo apt-get install python3 python3-pip
    sudo apt-get update
    echo "Python 3 is now installed." 
fi 

pip3 install biopython

chmod 744 *.sh
chmod 744 saligner
chmod 744 scripts/*.sh

