#!/usr/bin/env bash

# Push all repositories to github

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "$DIR/utils.sh"


usage() {
    echo "$0 --source-dir SOURCEDIR [--dry-run] [--help]"
    echo "Push all repositories to github"
    echo
}

push_to_github() {
    local repo="$1"

    echo "Push ${repo} to github"
    [[ $DRYRUN != "yes" ]] && {
        echo
    }
}

remove_bitbucket_origin() {
    local repo="$1"

    echo "Remove bitbucket origin from ${repo}"
    [[ $DRYRUN != "yes" ]] && {
        [[ -n $(git remote) ]] && {
            git remote remove origin
        }
    }
}

add_github_origin() {
    local repo="$1"

    echo "Add github origin to ${repo}"
    [[ $DRYRUN != "yes" ]] && {
        git remote add origin git@github.com:"${organization}/${repo}".git
        git push -u origin master
    }
}

process_directory() {
    for dir in "${sourcedir}"/*; do
        repo=$(basename "$dir")
        is_git "${sourcedir}/${repo}" && {
            cd "${sourcedir}/${repo}" || exit 1
            remove_bitbucket_origin "${repo}"
            add_github_origin "${repo}"
            push_to_github "${repo}"
            cd ..
        }
    done
}

DRYRUN=no
while [[ $1 ]]; do
    case "$1" in
        --dry-run)
            DRYRUN=yes
            ;;
        --organization|--org)
            organization="$2"
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

[[ -z $organization ]] || [[ -z $sourcedir ]] && { usage; exit 1; }

process_directory "${sourcedir}"
