#!/usr/bin/env bash

# Switch origin remote from bitbucket to github

organization=$1
[[ -z $organization ]] && { echo "Must suply organization."; exit 1; }

if [[ $(git remote -v | cut -f 1 | uniq) == "origin" ]]; then
    if [[ $(git remote -v | cut -f 2 | grep push) =~ git@bitbucket.org ]]; then
        origin=$(git remote -v | grep "\(push\)" | cut -f 2 | cut -d ' ' -f 1)
        repo=$(echo "$origin" | sed -E -e 's/^.*:([a-zA-Z]+)\/(.*)\.git/\2/' )

        git remote remove origin
        git remote add origin git@github.com:"${organization}/${repo}".git

        git fetch
        git branch --set-upstream-to=origin/master master

        git remote -v
    else
        echo "No bitbucket remote found."
        exit 1
    fi
else
    echo "No origin remote found."
    exit 1
fi
