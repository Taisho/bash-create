#!/usr/bin/env bash

# This is an example of how create can be invoked with a varieties of options
# ### Create Bash script
# create --bash -S %i%I-34;32;78;%OPO
# create --bash %i%I-34;32;78;%OPO
# create -B scriptname
#

# TODO If no code is provided from the command line, fail back to some kind of Hello-World
# Or better - try to guess it from file name.


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
        echo "bash"
        return 0
    ;;
    "$tsProjects"*)
        echo "ts"
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

function consume-long-options {
    local option="$1"
    local return=-1

    case "$option" in
    typescript | ts | TypeScript)
        language=ts
        return=0
    ;;
    html )
        export USE_HTML=1
        return=0
    ;;
    esac

    return $return
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
        language="bash"
    fi

    # - Keep in mind that for convenience  we will fall back to a default code if
    # - the user didn't supply any. 
    local code
    if [ -n "$1" ]
    then
        code="$1"
    elif [ -n "$CODE" ]
    then
        code="$CODE"
    else
        eval code=\$\{DefaultCode[$language]\}
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
            eval templateDir=$templateDir

            if [ -z "$templateDir" ]
            then
                echo >&2 "Unkown template %$tplRef. Your file will be missing stuff"
                code=${code#%*;}
                continue
            fi

            cd "$templateDir"
            if [ $? '!=' 0 ]
            then
                echo >&2 "Error. Directory $templateDir is unaccessable. "
            else
                template="$($SHELL controller.sh $tplOptions)"
                if [ "$CREATEOUTPUT" '==' "stdout" ]
                then
                    echo "$template"
                else
                    echo "$template" >> "$filename"
                fi
            fi

            code=${code#%*;}
        else
            continuee=false
        fi
    done

    if [ -e "$filename" ]
    then
        chmod u+x "$filename"
    else
        echo
        echo "No files were spawned, perhpas because no templates matched, or they were configured incorrectly"
    fi
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
        consume-long-options "${BASH_REMATCH[1]}"
        if [ $? != 0 ]
        then
            continue

        elif [[ -v ${BASH_REMATCH[1]} ]]
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
        
    elif [[ $1 =~ -(.*)$ ]]
    then
        opts="${BASH_REMATCH[1]}"
        end=$((${#opts}))
        for i in `seq 0 $end`
        do
            char=${opts:$i:1}

            case "$char" in
            B )
                language=bash
            ;;
            esac

        done
    else
        filename="$1"
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
