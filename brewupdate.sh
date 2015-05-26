#!/bin/bash
# ############################################################################
# NAME: brewupdate.sh
# DESC: Script to update, upgrade and check (doctor) Homebrew.
# ############################################################################

set -e

terminal-notifier -title 'Homebrew' -message 'Updating and upgrading.'
brew update
brew cask update
brew upgrade brew-cask
brew upgrade --all
brew cleanup
brew cask cleanup
brew doctor
