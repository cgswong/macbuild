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
# #############################################

# Setup file variable
CFG_FILE="$(basename ${0%.*}).cfg"

# Setup directories
mkdir ~/repos/{git,vagrant,scripts}

# Setup brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# -- Binary Installation
# Run configuration file to setup arrays
. ./${CFG_FILE}

echo "Installing binaries..."
brew tap homebrew/binary
brew install ${binaries[@]}
brew cleanup

# -- Cask Apps Installation
# Setup beta installations by tapping the versions cask
brew tap caskroom/versions

echo "Installing apps..."
# Default is ~/Applications, install instead to /Applications
brew cask install --appdir="/Applications" ${apps[@]}

# Use tap for installing fonts
brew tap caskroom/fonts

# -- Font Installation
# Install fonts
echo "Installing fonts..."
brew cask install ${fonts[@]}

## EOF ##