#!/usr/bin/env bash


localBinary=~/bin/create

if [ -e "$localBinary" ]
then
    mv $localBinary $localBinary.new-$RAND
    if [ $? '!=' 0  ]
    then
        echo &>2 "Failed to back up $localBinary destination exists"
        exit 1
    fi
fi

binary="$(realpath create.sh)"
cd ~/bin
ln -s "$binary" create

echo "Command \"create\" successfully installed in $HOME/bin"
