# MacBuild #

## Overview
This project facilitates a simple set up of a Mac computer using standard scripting. That is, following a base image, these bash scripts use [HomeBrew][homebrew] to install software components, followed by some configuration/customization of dot files which most developers will appreciate.

**brewupdate** is a [launchd agent][launchd] to update [homebrew][homebrew] formulae automatically every 5 days at 11 AM (local time).

**brewsetup** is a simple bash script to install [homebrew][homebrew] and setup your Mac OS with a list of various binaries and applications as given by the dependent configuration file *brewsetup.cfg*.

For further information check the respective markdown files:

  - [brewupdate.md](https://github.com/cgswong/macbuild/blob/master/brewupdate.md)
  - [brewsetup.md](https://github.com/cgswong/macbuild/blob/master/brewsetup.md)

[launchd]: http://developer.apple.com/library/mac/#technotes/tn2083/_index.html
[homebrew]: https://github.com/mxcl/homebrew/
