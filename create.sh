#!/usr/bin/env bash

#use strict

if [ -z "$*" ]
then
    echo "Usage \`create\` [OPTIONS] [FILENAME] ..."
    echo
    echo "Creates single or multiple files depending on options. \`create\` "
    echo "creates files using templates"
fi

function tell_language {
    if [ ! -e ~/.rcpaths ]
    then
        return 1
    fi

    source ~/.rcpaths

    case "$PWD" in
        "$bashProjects")
            echo "bash"
            return 0
            ;;
    esac
}

declare language=$(tell_language)

while test -n "$1" 
do
    if [[ $1 =~ --([^=]+)$ ]]
    then
        if [[ -v ${BASH_REMATCH[1]} ]]
        then
            option="$1"
            shift
            if [ -z "$1" ]
            then
                echo "$option requires an argument" &>/dev/stderr
            else
                eval ${BASH_REMATCH[1]}="$1"
            fi
        else
            echo "Unknown option $1" &>/dev/stderr
        fi
    elif [[ $1 =~ (--([^=]+))=(.*)$ ]]
    then
        if [[ -v ${BASH_REMATCH[2]} ]]
        then
            option="${BASH_REMATCH[1]}"
            variable="${BASH_REMATCH[2]}"
            value="${BASH_REMATCH[3]}"
            if [ -z "$value" ]
            then
                echo "$option requires an argument" &>/dev/stderr
            else
                eval $variable="\"$value\""
            fi
        else
            echo "Unknown option $option" &>/dev/stderr
        fi
    elif [[ $1 =~ -(.*)$ ]]
    then
        :
    fi

#    case "$1" in
#    --bash)
#        language=bash
#    ;;
#    --[^=])
#       shift
#       language="$1" 
#    ;;
#    --language=*)
#       language=${1#*=}
#    esac
    shift
done

echo $language
