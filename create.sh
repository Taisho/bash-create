#!/usr/bin/env bash

# This is an example of how create can be invoked with a varieties of options
# ### Create Bash script
# create --bash -S %i%I-34;32;78;%OPO
# create --bash %i%I-34;32;78;%OPO
# create -B scriptname
#

#use strict
if [ ! -e ~/.create ]
then
    echo >&2 "Cannot locate .template_map"
    echo >&2 "Please make sure to run install.sh"
    echo >&2 "Exitting"

    exit 1
fi
source ~/.create

if [ ! -e ~/.template_map ]
then
    echo >&2 "Cannot locate .template_map"
    echo >&2 "Please make sure to run install.sh"
else
    source ~/.template_map
fi


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
        "$bashProjects"*)
            echo "Bash"
            return 0
            ;;
    esac
}

function create_filename {
    name="$(basename "$PWD").sh"

    while [ -e "$name" ]
    do
        name="+$name"
    done

    echo "$name"
}


declare language=$(tell_language)
declare filename="$(create_filename)"

declare CODE

function feed-code {
    if [ -z "$CODE" ]
    then
        CODE="$1"
    else
        CODE="$CODE $1"
    fi
}

function name2code {
    local code
    local ret=1
    if [[ $filename =~ ^cut.*sh$ ]]
    then
        code='%C;'
        ret=0
    fi

    echo "$code"
    return $ret
}

function interpret {
    if [ -z "$filename" ]
    then
        echo >&2 "Varibale File is not set. Aborting"
        return 1
    fi

    if [ -e "$filename" ]
    then
        echo >&2 "filename $filename exists. Aborting"
        return 1
    fi

    if [ -z "$language" ]
    then
        echo >&2 "Language is unclear. Attempting to create shell script"
        echo >&2 "Please give me --language option"
    fi

    local code
    if [ -n "$1" ]
    then
        code="$1"
    else
        code="$CODE"
    fi

    if [ -z "$code" ]
    then
        code="$(name2code)"
    fi

    # We need well formatted code
    if [ "${code: -1}" != ';' ]
    then
        code="$code;"
    fi

    local tplRer
    local continuee=true
    while test $continuee '==' true
    do
        if [[ $code =~ %(([^; %-])+(-([^;]+);)?) ]]
        then
            tplRef="${BASH_REMATCH[2]}" 
            tplOptions="${BASH_REMATCH[4]}"

            eval "local templateDir=\$\{\"${language^}\"Template[$tplRef]\}"
            if [ -z "$templateDir" ]
            then
                echo >&2 "Unkown template %$tplRef. Your file will be missing stuff"
                code=${code#%*;}
                continue
            fi
            eval templateDir=$templateDir

            cd "$templateDir"
            if [ $? '!=' 0 ]
            then
                echo >&2 "Error. Directory $templateDir is unaccessable. "
            else
                template="$($SHELL controller.sh $tplOptions)"
                echo "$template" >> "$filename"
            fi

            code=${code#%*;}
        else
            continuee=false
        fi
    done
}

# Reading configuration from command line
# We support configuring all global variables
# here via the command line.
# There are shortcut keys for particular cases
# in order to save on key strokes
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
                echo "$option requires an argument" >/dev/stderr
            else
                eval ${BASH_REMATCH[1]}="$1"
            fi
        else
            echo "Unknown option $1" >/dev/stderr
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
                echo "$option requires an argument" >/dev/stderr
            else
                eval $variable="\"$value\""
            fi
        else
            echo "Unknown option $option" >/dev/stderr
        fi
    elif [[ $1 =~ %(.*)$ ]]
    then
        feed-code "$1"
    else
        case "$1" in
        --bash | -B )
            language=bash
        ;;
        * )
            filename="$1"
        ;;
        esac
    fi

    shift
done

# Now that the configuration is loaded from the command line we would like
# to make sure that it is well formatted and out of errors. For example
# file names should always be absolute paths, but for convenience we
# support relative paths on the command line and convert them to absolute
# here

filename="$(realpath "$filename")"


# And finally invoke templates. This is done via the interpret command
# (I'm considering a better name for it ^_^) which will find the corr-
# esponding templates and invoke their controller scripts with its co-
# nfiguration that is comming from the command line (if any)

interpret
