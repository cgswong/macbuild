# MacBuild

**macBuild** configures a macOS computer. It installs applications, tools, packages, and configures the user profile. This includes:

- [x] [Homebrew][homebrew] packages
- [x] Applications using [Homebrew][homebrew]
- [x] Python packages using [pipx](https://pypa.github.io/pipx/)
- [x] Node JavaScript packages using [npm](https://www.npmjs.com/)

## Requirements

**macBuild** tries to handle installation requirements on a best effort basis. Not for itself, it uses regular bash-ism, but for the tooling used for the installations. This includes the installation of the XCode command line tools.

## Installation

To install **macBuild** you can use the below:

```bash
curl -sSL https://raw.githubusercontent.com/cgswong/macbuild/bin/macbuild | bash -s
```

For a more cautious approach, download the repository and execute the file locally.

## Packages and Applications

For the full list of packages and applications that get installed see the [packages list](file/packages.ini)

You can also specify the location of your environment files (the "dotfiles") in your GitHub repository, and **macBuild** will download and install. My [dotfiles](https://github.com/cgswong/dotfiles) are used as the default.

## Getting updates

A [launchd agent][launchd] is used to schedule updates to [Homebrew][homebrew] formulae automatically every 5 days at 11:00 am (local time).

[launchd]: http://developer.apple.com/library/mac/#technotes/tn2083/_index.html
[homebrew]: https://brew.sh/
