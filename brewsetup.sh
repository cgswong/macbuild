#!/bin/bash
# #############################################
# DESC: Script to setup Mac computers with software
#       using 'brew' and 'brew cask' commands.
#       May need to install Xcode and the Xcode command line tools.
# #############################################

# Fail fast
set -eo pipefail

# Set package name
pkg=${BASH_SOURCE##*/}

# Setup file variable
: ${CFG_FILE:="$(basename ${0%.*}).cfg"}

# set colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)

# Write messages to screen
log() {
  echo "$(date +"%F %T") [${pkg}] $1"
}

# Write exit failure messages to syslog and exit with failure code (i.e. non-zero)
die() {
  log "${red}[FAIL] $1${reset}" && exit 1
}

# Setup directories
log "Creating some directories..."
[ ! -d ~/repos/git ] && mkdir -p ~/repos/git
[ ! -d ~/repos/git ] && mkdir -p ~/repos/vagrant
[ ! -d ~/repos/git ] && mkdir -p ~/repos/scripts

# Setup brew
log "Installing HomeBrew..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# -- Binary Installation
# Run configuration file to setup arrays
log "Loading brews..."
. ./${CFG_FILE}

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

log "Setting taps..."
brew tap homebrew/binary
brew tap homebrew/dupes
brew tap pivotal/tap
log "Installing binaries..."
brew install ${binaries[@]}

# Remove outdated versions from the cellar.
log "Removing outdated versions from cellar..."
brew cleanup

# -- Cask Apps Installation
# Setup beta installations by tapping the versions cask
log "Setup Cask versions..."
brew tap caskroom/versions

log "Installing Cask Apps..."
# Default is ~/Applications
#brew cask install --appdir="/Applications" ${apps[@]}
brew cask install ${apps[@]}

# Use tap for installing fonts
log "Setup Cask fonts..."
brew tap caskroom/fonts

# -- Font Installation
# Install fonts
log "Installing Cask fonts..."
brew cask install ${fonts[@]}

# Remove outdated versions from the cellar.
log "Cask cleanup..."
brew cask cleanup

# Install automated brew update
log "Installing Brew updater..."
$(dirname ${0})/brewupdate-install.sh
log "MacBuild complete!"
