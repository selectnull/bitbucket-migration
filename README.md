bitbucket to github migration
=============================

[Bitbucket has announced sunsetting Mercurial support](
(https://bitbucket.org/blog/sunsetting-mercurial-support-in-bitbucket)
and they will delete all mercurial repositories by July 1, 2020.

I can quite honestly understand the bitbucket decision, mercurial simply
didn't win enough source control market share and to support it has its
costs (and to deprecate it has its consequences).

This is a set of bash scripts to migrate mercurial and/or git
repositories hosted at bitbucket.org to github.com. The code has been
tested and works, but it's not really meant to be used without
understanding of how it works. Feel free to modify for your own needs.

Requirements
------------

These scripts require bash (probably work in other shells but I haven't
tested it) with few external dependencies:

* git
* hg
* jq
* python
* diff
* fast-export


Clone repositories from bitbucket
---------------------------------

We'll use bitbucket API to get a list of all repositories and for that
we need to create app password to access the data. App passwords are
definitely easier to use than OAuth2. Go to [bitbucket
settings](https://bitbucket.org/account/settings/app-passwords/) and
create new app password. After the migrations is done, you can delete
it. Create a file called `.bitbucket-credentials` with this content:

    USERNAME|PASSWORD

After that, run a script to clone all repositories locally.

    ./clone-from-bitbucket.sh --team TEAM --output-dir PATH-TO-EMPTY-OUTPUT-DIRECTORY

You will get a mix of `git` or `hg` repositories.

Convert hg to git
-----------------

Once you have all the repositories, you need to convert `hg`
repositories to `git`. Conversion is done by excellent
[fast-export](https://github.com/frej/fast-export) tool. Clone it
locally and follow its install instructions. I recommend you
install `mercurial` into empty python virtual environment
so you don't clutter the system packages but that's optional.

Run the script with:

    ./convert-hg-to-git.sh \
        --sourcedir PATH-TO-CLONED-BITBUCKET-REPOSITORIES \
        --targetdir PATH-TO-EMPTY-DIR \
        --fast-export PATH-TO-FAST-EXPORT-PROGRAM
        --fast-export-venv PATH-TO-VIRTUAL-ENVIRONMENT

This will convert all mercurial repositories from `sourcedir` to `git`
and save them to `targetdir`. Any `git` repository will be skippped.

You can check that everything has been converted properly with:

    ./diff-dirs.sh PATH-TO-CLONED-BITBUCKET-REPOSITORIES PATH-TO-CONVERTED-GIT-REPOSITORIES

Create empty repositories on Github
-----------------------------------

You need a repository to push the code to, so let's create them. This
time we'll use Github API and you (just like with bitbucket) need to
create [personal access token](https://github.com/settings/tokens).
Create a file `.github-credentials` with the content:

    USERNAME|PASSWORD

Run the script:

    ./create-github-repo.sh --organization ORGANIZATION --source-dir PATH-TO-GIT-REPOSITORIES


Push to github
--------------

Finally, you need to push the code to github.

    ./push-to-github.sh --source-dir PATH-TO-GIT-REPOSITORIES

If you had a mix of git and hg repositories, following these scripts
would have created two different root directories where repository are,
so you would need to run this script for both paths.


Licence
-------

The code in this repository is MIT licensed.
