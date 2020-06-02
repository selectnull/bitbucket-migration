#!/usr/bin/env bash

# Clone all repositories from bitbucket.org

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "$DIR/utils.sh"

clone_repo() {
    local repo=$1
    local scm=$2

    # check that scm is either hg or git
    [[ $scm != hg && $scm != git ]] && exit 1

    echo "$scm clone $repo"
    [[ $DRYRUN != "yes" ]] && "$scm" clone "$repo"
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
    response=$(curl -su "$USERNAME:$PASSWORD" "$url")
    handle_response "$response"

    local next_page
    next_page=$(jq --raw-output '.next' <<< "$response")
    [[ $next_page != "null" ]] && fetch_response "$next_page"
}

usage() {
    echo "$0 team"
    echo "Clone all <team> repositories from bitbucket.org"
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
        --output-dir)
            outputdir="$2"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
    esac
    shift
done

read_credentials .bitbucket-credentials

olddir=$(pwd)
cd "$outputdir" || exit 1

[[ -z $team ]] && { usage; exit 1; }
fetch_response "https://api.bitbucket.org/2.0/repositories/$team"

cd "$olddir" || exit 1
