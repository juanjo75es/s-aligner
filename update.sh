#!/bin/bash

version=$(LD_LIBRARY_PATH=. ./saligner -version 2>&1 >/dev/null)

version=${version:9}

content=$(wget contignant.com/remote/update?v=$version -q -O -)

VAR2="update"
if [ "$content" = "$VAR2" ]; then

    wget http://contignant.com/remote/get_updater_script?v=$version -q -O newupdate.sh
    if test -f "newupdate.sh"; then
        ./newupdate.sh
    fi
    rm newupdate.sh

    wget http://contignant.com/remote/get_new_version?v=$version -q -O newversion.zip
    unzip -o newversion.zip 
    rm newversion.zip
else
    echo "Nothing to update."
fi