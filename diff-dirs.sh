#!/usr/bin/env bash

sourcedir=$1
targetdir=$2

usage() {
    echo "Usage: $0 source-directory target-directory"
    echo
}

[[ -z $sourcedir || -z $targetdir ]] && {
    usage
    exit 1
}

for dir in "$sourcedir"/*; do
    repo=$(basename "$dir")
    diff --recursive "$sourcedir/$repo" "$targetdir/$repo"
done
