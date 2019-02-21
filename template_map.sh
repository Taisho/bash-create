#!/usr/bin/env bash

declare -A BashTemplate
declare templateDir="$workingDir/templates/bash"

BashTemplate[I]="$templateDir/read-file-line-by-line"
BashTemplate[C]="$templateDir/cut-tracks"
