# MacBuild

This project facilitates a simple set up of a macOS computer using standard scripting and Ansible. Specifically, bash scripting, Ansible, and [HomeBrew][homebrew] are used to install software components, including customization using dot files.

## Requirements/Dependencies

Installation requirements and dependencies are handled by the `macbuild` script. Specifically:

- geerlingguy.dotfiles
- geerlingguy.homebrew
- geerlingguy.mas

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/cgswong/macbuild/bin/macbuild | bash -s -- --install
```

## Running a specific set of tagged tasks

You can filter which part of the provisioning process to run by specifying a set of tags using the `--tags` flag (maps to same option as `ansible-playbook`). The tags available are:

- `dotfiles`
- `extra-packages`
- `homebrew`
- `mas`
- `osx`

```bash
macbuild --tags="dotfiles,homebrew"
```

## Role Variables

Available variables are listed below along with default values. See `defaults/main.yml` for current listing.

- `configure_dotfiles` - Flag to install the dotfiles (default: `yes`).
- `configure_osx` - Flag to setup the OSX dotfile (default: `yes`).
- `osx_script` - Execution command for running the OSX dotfile (default: `~/.osx --no-restart`).
- `dotfiles_repo` - Git repository to get dotfiles (default: `https://github.com/cgswong/dotfiles.git`)
- `dotfiles_repo_accept_hostkey` - Flag to accept the hostkey when downloading from remote Git repository (default: `yes`).
- `dotfiles_repo_local_destination` - Local directory to keep dotfiles (default: `~/dotfiles`). Each dotfile in your home directory is linked to the respective file in this location.
- `homebrew_installed_packages` - List of packages to install using Homebrew. See the [packages section](#Packages) for the defaults.
- `homebrew_cask_apps` - List of applications to install using Homebrew Cask. See the [applications section](#Applications) for the defaults.
- `homebrew_upgrade_all_packages` - Flag to keep packages updated automatically (default: `yes`).
- `homebrew_taps` - Homwebrew taps to use for installations.
- `homebrew_cask_appdir` - Default installation location for Homwebrew Cask applications (default: `/Applications`).
- `mas_installed_apps` - List of applications to install from Mac App Store. This requires the application ID and name which you can get with `mas list` or `mas search [app name]` to search for an application once you have installed [mas](https://github.com/geerlingguy/ansible-role-mas).
- `mas_email` - Your email used to sign into the Mac App Store.
- `mas_password` - Your Mac App Store password. I would recommend using `vars_prompt` to get prompted for this password, or using [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html) or [HashiCorp Vault](https://www.vaultproject.io/) to provide better credential management for a static password.
- `mas_upgrade_all_apps` - Flag to keep Mac App Store applications current.
- `gem_packages` - List of [Ruby Gems](https://rubygems.org/) to install. Requires:
    - **name**: Name of Gem to install, uninstall
    - **state**: present/absent/latest (default: present)
    - **version** (optional Gem version)
- `npm_packages` - List of [Node.js packages](https://www.npmjs.com/) to install using **NPM**. Requires:
    - **name**: Name of package to install, uninstall
    - **state**: present/absent/latest (default: present)
    - **version** (optional package version)
- `pip_packages` - List of [Python packages](https://pypi.python.org/pypi) to install using **pip**. Requires:
    - **name**: Name of package to install, uninstall
    - **state**: present/absent/latest (default: present)
    - **version** (optional package version)
- `post_provision_tasks` - Post provisioning tasks to run.

## Overriding defaults

Since not everyone's environment or preferred software configuration is the same, you can easily customize to suite. Customization is done by overriding the `defaults/main.yml` file using your own `vars/config-[username].yml` file and setting your own overrides in that file. For example:

```
homebrew_installed_packages:
  - cowsay
  - git
  - go

mas_installed_apps:
  - { id: 557168941, name: "Tweetbot" }
  - { id: 497799835, name: "Xcode" }

gem_packages:
  - name: bundler
    state: latest

npm_packages:
  - name: webpack

pip_packages:
  - name: mkdocs
```

## Default Included Packages and Applications

### Packages

Homwebrew installations:

- asciicinema
- asciidoc
- autoconf
- automake
- autossh
- awless
- awscli
- bash
- bash-completion
- bats
- binutils
- cf-cli
- cli53
- corectl
- coreutils
- cowsay
- curl
- diffutils
- direnv
- dnsmasq
- dnsperf
- dnstracer
- docbook
- doxygen
- elixir
- elm
- etcd
- fdupes
- ffmpeg
- figlet
- file-formula
- findutils
- fleetctl
- fontconfig
- gawk
- gettext
- ghostscript
- gifsicle
- git
- git-extras
- git-flow
- git-secrets
- giter8
- github-release
- go
- godep
- gnu-sed
- gnu-tar
- gnu-which
- gnupg2
- gnutls
- gpatch
- grep
- gzip
- htop
- httpie
- httpstat
- hub
- hugo
- icu4c
- iperf
- jq
- kibana
- kops
- kube-aws
- kubernetes-cli
- kubernetes-helm
- lame
- less
- libevent
- lynx
- make
- mcrypt
- mkdocs
- neovim
- nmap
- node
- nomad
- nvm
- openssh
- packer
- pandoc
- pssh
- pv
- pwgen
- pyenv
- pyenv-virtualenv
- pyenv-virtualenvwrapper
- rbenv
- rename
- rsync
- s3cmd
- screen
- slackcat
- ssh-copy-id
- sshfs
- tcptrace
- terminal-notifier
- terraform
- tree
- unzip
- vault
- vim
- watch
- wdiff
- webkit2png
- wget
- wrk
- zsh
- zsh-completions  

### Applications

Homebrew Cask installations:

- [Atom](https://atom.io/)
- [Chef Development Kit](https://downloads.chef.io/chefdk)
- [ClipMenu](http://www.clipmenu.com/)
- [Docker](https://www.docker.com/)
- [Etcher](https://etcher.io/)
- [Evernote](https://evernote.com/)
- [f.lux](https://justgetflux.com/)
- [GitHub Desktop]()
- [Google Chrome](https://www.google.com/chrome/)
- [Handbrake](https://handbrake.fr/)
- [ImageOptim](https://imageoptim.com/mac)
- [iTerm2](https://www.iterm2.com/)
- [Java](https://www.oracle.com/technetwork/java/javase)
- [KeyBase](https://keybase.io/)
- [LaunchControl](https://www.soma-zone.com/LaunchControl/)
- [LICEcap](http://www.cockos.com/licecap/)
- [ngrok](https://ngrok.com/)
- [pgAdmin4](https://www.pgadmin.org/)
- [Postman](https://www.getpostman.com/)
- [QLCcolorC`ode](https://github.com/anthonygelibert/QLColorCode)
- [QLMarkdown](https://github.com/toland/qlmarkdown)
- [QLStephen](https://whomwah.github.io/qlstephen/)
- [quick look JSON](http://www.sagtau.com/quicklookjson.html)
- [Recordit](http://recordit.co/)
- [Screenhero](https://screenhero.com/)
- [Skitch](https://evernote.com/skitch/)
- [Slack](https://slack.com/)
- [SourceTree](https://www.sourcetreeapp.com/)
- [SquidMan](https://squidman.net/squidman/)
- [The Unarchiver](https://unarchiver.c3.cx/unarchiver)
- [Tor Browser](https://www.torproject.org/projects/torbrowser.html)
- [Transmission](https://transmissionbt.com/)
- [UNetbootin](https://unetbootin.github.io/)
- [Vagrant](https://www.vagrantup.com/)
- [Vagrant Manager](http://vagrantmanager.com/)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [VirtualBox Extension Pack](https://www.virtualbox.org/)
- [VLC Media Player](https://www.videolan.org/vlc/)
- [Wireshark](https://www.wireshark.org/)
- [XMind](https://www.xmind.net/)

My [dotfiles](https://github.com/cgswong/dotfiles) are also installed into the current user's home directory, including the `.osx` dotfile for configuring aspects of macOS.

## Getting updates

A [launchd agent][launchd] is used to schedule updates to [Homebrew][homebrew] formulae automatically every 5 days at 11 AM (local time).

[launchd]: http://developer.apple.com/library/mac/#technotes/tn2083/_index.html
[homebrew]: https://github.com/mxcl/homebrew/
