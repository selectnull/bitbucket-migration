#!/usr/bin/env bash

is_hg() {
    is_repository "$1" hg
}

is_git() {
    is_repository "$1" git
}

is_repository() {
    directory=$1
    scm=$2
    test -d "$directory/.$scm"
}

read_credentials() {
    file="$1"
    oldifs=$IFS
    IFS="|"
    while read -r _username _password; do
        export USERNAME=$_username
        export PASSWORD=$_password
    done < "$file"
    IFS=$oldifs
}

