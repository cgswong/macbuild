#!/bin/bash
# ##########################################################
# DESC: Setup environment with dot files and brew for better productivity.
# ##########################################################

cd "$(dirname "${BASH_SOURCE}")"

# Pull latest version of dot files
git pull origin master

function doIt() {
  rsync --exclude ".git/" --exclude ".DS_Store" --exclude "*.md" -avh --no-perms dotFiles/ ~
  source ~/.bash_profile
  [ ! -d ~/.vim/swaps ] && mkdir -p ~/.vim/swaps
  [ ! -d ~/.vim/backups ] && mkdir -p ~/.vim/backups
  [ ! -d ~/.vim/undo ] && mkdir -p ~/.vim/undo

  # Run brew installation and setup
  ./brewsetup.sh

  # Get sudo access up front
  sudo -v

  # Install some linters
  sudo gem install puppet-lint
  sudo gem install yaml-lint
  sudo gem install travis-yaml

  # Install command line Markdown viewer
  sudo gem install octodown
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
