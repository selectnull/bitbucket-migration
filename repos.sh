#!/bin/bash

# Migrate git and hg repositories from bitbucket.org to github.com

read_credentials() {
    oldifs=$IFS
    IFS="|"
    while read -r _username _password; do
        username=$_username
        # shellcheck disable=SC2034
        password=$_password
    done < .apppass
    IFS=$oldifs
}

clone_repo() {
    local repo=$1
    local scm=$2

    # check that scm is either hg or git
    [[ $scm != hg && $scm != git ]] && exit 1

    echo "$scm clone $repo"
}

handle_response() {
    local response=$1
    local repos='.values[] | ({scm: .scm, name: .name, href: .links.clone[] | select(.name == "ssh").href})'
    for repo in $(jq --compact-output "$repos" <<< "$response"); do
        clone_repo "$(jq --raw-output '.href' <<< "$repo")" "$(jq --raw-output '.scm' <<< "$repo")"
    done
}

fetch_response() {
    local url=$1
    [[ -z $url ]] && exit 0

    echo "Fetching from: $url"

    local response
    response=$(curl -su "$username:$password" "$url")
    handle_response "$response"

    local next_page
    next_page=$(jq --raw-output '.next' <<< "$response")
    [[ $next_page != "null" ]] && fetch_response "$next_page"
}

read_credentials
fetch_response "https://api.bitbucket.org/2.0/repositories/logit"
