#!/usr/bin/env bash

declare -A BashTemplate
declare -A DefaultCode
declare templateDir="$workingDir/templates"

# - Defining template path
# - Bash
BashTemplate[I]="$templateDir/bash/read-file-line-by-line"

# - TypeScripts
TsTemplate[I]="$templateDir/typescript/read-file-line-by-line"

# Defining default code
DefaultCode[bash]="%I;"
