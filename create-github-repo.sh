#!/usr/bin/env bash

# Create github repository

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "$DIR/utils.sh"

read_credentials() {
    oldifs=$IFS
    IFS="|"
    while read -r _username _password; do
        username=$_username
        password=$_password
    done < "$DIR"/.github-credentials
    IFS=$oldifs
}

createrepo() {
    repo="$1"
    CREATEREPO="{\"name\": \"${repo}\", \"private\": true}"

    is_git "${sourcedir}/${repo}" && {
        echo "Create ${repo} repo for ${team}"
        [[ $DRYRUN != "yes" ]] && {
            curl --user "${username}:${password}" \
                --header "Content-Type: application/json" \
                --data "${CREATEREPO}" \
                "https://api.github.com/orgs/${team}/repos"
        }
    }
}

process_directory() {
    local dir="${sourcedir}"
    local team="${team}"
    for dir in "${sourcedir}"/*; do
        repo=$(basename "$dir")
        createrepo "${repo}"
    done
}

usage() {
    echo "$0 --team TEAM --source-dir SOURCEDIR [--dry-run] [--help]"
    echo "Create one github repository per each direcotry in source"
    echo
}


DRYRUN=no
while [[ $1 ]]; do
    case "$1" in
        --dry-run)
            DRYRUN=yes
            ;;
        --team)
            team="$2"
            ;;
        --source-dir)
            sourcedir="$2"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
    esac
    shift
done


[[ -z $team ]] || [[ -z $sourcedir ]] && { usage; exit 1; }

read_credentials
process_directory "${sourcedir}" "${team}"
