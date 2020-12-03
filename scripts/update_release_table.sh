#!/usr/bin/env bash

# Load environmental variables, generated during the build process
. vars.env

# Set the user name and email as Travis
git config --global user.name "GitHub Actions"
git config --global user.email "github-actions@github.com"

# Checkout the master branch (as we are right now on a tag)
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git fetch --all
git checkout master

# Add the new release row to the release table
echo "${release_new_row}" >> RELEASES.md

# Commit and push the change to master
git commit -a -m "Update RELEASES"
git remote set-url origin https://${GITHUB_TOKEN}@github.com/${REPO_SLUG}
git push origin master