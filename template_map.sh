#!/usr/bin/env bash

declare -A BashTemplate
declare -A DefaultCode
declare templateDir="$workingDir/templates"

# Defining default code
DefaultCode[bash]="%I;"

# - Defining template path
# - Bash
BashTemplate[I]="$templateDir/bash/read-file-line-by-line"
BashTemplate[C]="$templateDir/cut-tracks"

# - TypeScripts
TsTemplate[I]="$templateDir/typescript/read-file-line-by-line"
