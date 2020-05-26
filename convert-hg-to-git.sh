#!/usr/bin/env bash

# Convert Mercurial repositories in given directory to git

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "$DIR/utils.sh"

convert_hg_to_git() {
    local sourcerepo=$1

    repo=$(basename "$sourcerepo")
    echo "Converting $repo: from $sourcerepo to $targetdir/$repo"
    [[ $DRYRUN != "yes" ]] && {
        cd "$targetdir" || exit 1

        {
            git init "$repo"
            cd "$repo"
            git config core.ignoreCase false
        } || exit

        # WARNING Understand the use of --force switch and mercurial unnamed heads!
        "${fast_export}" -r "$sourcerepo" --force || {
            echo "Error running hg-fast-export.sh"
            exit 1
        }
        git checkout master
    }
}

process_repositories() {
    local sourcedir=$1
    for repo in "$sourcedir/"*; do
        is_hg "$repo" && {
            convert_hg_to_git "$repo"
        }
    done
}

usage() {
    echo "$0 --target targetdir --fast-export PATH-TO-FAST-EXPORT [--source sourcedir] [--fast-export-venv PATH-TO-VENV] [--dry-run]"
    echo "Convert hg repository to git"
    echo
}

DRYRUN=no
while [[ $1 ]]; do
    case "$1" in
        --dry-run)
            DRYRUN=yes
            ;;
        --target)
            targetdir="$2"
            ;;
        --source)
            sourcedir="$2"
            ;;
        --fast-export)
            fast_export="$2"
            ;;
        --fast-export-venv)
            fast_export_venv="$2"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
    esac
    shift
done

[[ -z $sourcedir ]] && sourcedir=$(pwd)
[[ -z $targetdir ]] && {
    echo "Must specify target directory (--target)."
    exit 1
}

# activate fast-export virtual environment if set
# shellcheck disable=SC1090
[[ $fast_export_venv ]] && source "$fast_export_venv/bin/activate"

olddir=$(pwd)

process_repositories "$sourcedir" "$targetdir"

cd "$olddir" || exit 1
