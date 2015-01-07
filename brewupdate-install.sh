#!/bin/bash
# ############################################################################
# NAME: brewupdate-install.sh
# DESC: Script to setup launchd process to update, upgrade and check (doctor)
#       for brew.
#
# LOG:
# yyyy/mm/dd [user] [version]: [notes]
# 2014/01/07 cgwong v1.0.0: Re-created from modified and https://github.com/cgswong/brewupdate/blob/develop/brewupdate-install.sh
# ############################################################################

set -e

AGENTS="$HOME/Library/LaunchAgents"
PLIST="$AGENTS/net.brewupdate.agent.plist"
REPO=${REPO:-cgswong}
BRANCH=${BRANCH:-master}
REMOTE="https://github.com/$REPO/macbuild/raw/$BRANCH/net.brewupdate.agent.plist"

[ -f "$PLIST" ] && launchctl unload "$PLIST"
if [ "$1" == "uninstall" ]; then
  rm -f "$PLIST"
  if [ $? -eq 0 ]; then
    echo "Unloaded brewupdate."
    exit 0
  else
    echo "Failed unloading brewupdate!!"
    exit 1
  fi
fi

curl -L "$REMOTE" >| "$PLIST"
[ -f "$PLIST" ] && launchctl load "$PLIST"
if [ $? -eq 0 ]; then
  echo "Loaded brewupdate."
  exit 0
else
  echo "Failed loading brewupdate!!"
  exit 1
fi
