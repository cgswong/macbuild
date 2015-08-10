#!/bin/bash
# #############################################
# NAME: brewsetup.sh
#
# DESC: Script to setup Mac computers with software
#       using 'brew' and 'brew cask' commands.
#       May need to install Xcode and the Xcode command line tools.
#
# LOG
# yyyy/mm/dd [name]: [version][notes]
# 2015/01/07 cgwong: v0.1.0 Initial creation from notes.
# 2015/01/08 cgwong: v1.0.0 Added cleanup, and sudo.
# 2015/02/11 cgwong: v1.0.1 Added brew update script.
# #############################################

# Fail fast
set -eo pipefail

# Setup file variable
CFG_FILE="$(basename ${0%.*}).cfg"

# Setup directories
echo "Creating directories as required..."
[ ! -d ~/repos/git ] && mkdir -p ~/repos/git
[ ! -d ~/repos/git ] && mkdir -p ~/repos/vagrant
[ ! -d ~/repos/git ] && mkdir -p ~/repos/scripts

# Setup brew
echo "Install HomeBrew..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# -- Binary Installation
# Run configuration file to setup arrays
echo "Loading brews..."
. ./${CFG_FILE}

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

echo "Setting taps..."
brew tap homebrew/binary
brew tap homebrew/dupes
brew tap pivotal/tap
echo "Installing binaries..."
brew install ${binaries[@]}

# Remove outdated versions from the cellar.
brew cleanup

# -- Cask Apps Installation
# Setup beta installations by tapping the versions cask
brew tap caskroom/versions

echo "Installing apps..."
# Default is ~/Applications
#brew cask install --appdir="/Applications" ${apps[@]}
brew cask install ${apps[@]}

# Use tap for installing fonts
brew tap caskroom/fonts

# -- Font Installation
# Install fonts
echo "Installing fonts..."
brew cask install ${fonts[@]}

# Remove outdated versions from the cellar.
brew cask cleanup

# Install automated brew update
echo "Installing Brew updater..."
$(dirname ${0})/brewupdate-install.sh
