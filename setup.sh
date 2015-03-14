#!/bin/bash
# ##########################################################
# NAME: setup.sh
#
# DESC: Setup environment with dot files and brew for better productivity.
#
# LOG: yyyy/mm/dd [name]: [version] [notes]
# 2015/02/11 cgwong: 1.0.0 Created from reference notes and steps.
# ##########################################################

cd "$(dirname "${BASH_SOURCE}")"

# Pull latest version of dot files
git pull origin master

function doIt() {
  rsync --exclude ".git/" --exclude ".DS_Store" --exclude "*.md" -avh --no-perms dotFiles/ ~
  source ~/.bash_profile
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi
unset doIt