#!/bin/bash
# ############################################################################
# NAME: brewupdate.sh
# DESC: Script to update, upgrade and check (doctor) Homebrew.
# ############################################################################

terminal-notifier -title 'Homebrew' -message 'Updating and upgrading.'
echo "Running 'brew update'."
brew update
echo "Running 'brew cask update'."
brew cask update
echo "Attempting to upgrade brew cask."
brew upgrade brew-cask
echo "Attempting to upgrade all brews."
brew upgrade --all
echo "Doing cleanup."
brew cleanup
brew cask cleanup
brew doctor

