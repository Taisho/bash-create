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

olddir="$PWD"
binary="$(realpath create.sh)"
template_map="$(realpath template_map.sh)"
if [ ! -e "$binary" ]
then
    echo &>2 "Cannot locate create.sh"
    echo &>2 "Aborting"
    exit 1
fi

cd ~/bin
ln -s "$binary" create

cd ~/
ln -s "$template_map" .template_map

if [ -e .create ]
then
    echo &>2 "File .create exists. Not overwriting"
else
    echo "declare workingDir=$olddir" > .create
fi

