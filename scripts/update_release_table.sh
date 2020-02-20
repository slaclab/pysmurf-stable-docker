#!/usr/bin/env bash

. vars.env

git config --global user.name "Travis CI"
git config --global user.email "travis@travis-ci.com"
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git fetch --all
git checkout master
echo "${release_new_row}" >> RELEASES.md
git commit -a -m "Update RELEASES"
git remote set-url origin https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}
git push origin master