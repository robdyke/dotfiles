#!/bin/bash
# This script installs dependencies required by dotfiles, and then the configuration files with git repo.

# CAVEAT: nvim not installed on raspbian (apt version too old)

ORIGIN=https://github.com/naggie/dotfiles.git

set -e
set -x

# platform detection. Desktop is always a superset of server.
if [ $(uname) == 'Darwin' ]; then
    export MACOS=1
    export MACOS_DESKTOP=1
elif grep -q Ubuntu /etc/issue; then
    export UBUNTU=1
    if dpkg -l | grep -vq landscape; then
        export UBUNTU_DESKTOP=1
    fi
elif grep -q Raspbian /etc/issue; then
    export RASPBIAN=1
else
    echo "Unsupported OS."
    exit 2
fi


# tmpreaper tries to do a post-install "configuration" screen to warn the user.
export DEBIAN_FRONTEND=noninteractive

# packages are installed via the stock system package manager unless a more
# recent version is available elsewhere.

if [ $MACOS_DESKTOP ]; then
    if [ ! -f /usr/local/bin/brew ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi

    # recommended, uses /Applications now.
    brew tap caskroom/homebrew-cask
    brew cask install spectacle firefox

    # flux is no longer required -- night shift!

    # Upgrade or install (logic necessary)
    packages=(tmux vim git tig httpie ncdu tree bash pass zsh openssh jq wget task htop gnupg2 bash-completion keychain iproute2mac tmpreaper \
        coreutils sox ffmpeg httrack python ripgrep python go)
    for package in "${packages[@]}"; do
        brew upgrade $package || brew install $package
    done

    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade ansible ipython

    # correct so alias works cross platform
    ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2
fi

if [ $UBUNTU ]; then
    sudo -E apt-add-repository multiverse
    sudo -E apt-get -y install language-pack-en
    sudo -E apt-get -y install curl
    # FYI -- ripgrep is an official 18.04 package
    curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb > /tmp/ripgrep.deb
    sudo dpkg -i /tmp/ripgrep.deb
    rm /tmp/ripgrep.deb
fi

if [ $RASPBIAN ]; then
    curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz \
        | sudo tar -C /usr/local/bin --strip=1 -xzf - ripgrep-0.10.0-arm-unknown-linux-gnueabihf/rg
fi

if [ $UBUNTU ] || [ $RASPBIAN ]; then
    sudo -E apt-get -y update
    sudo -E apt-get -y install tmux vim git tig zsh ssh pass figlet httpie ncdu tree wget htop gnupg2 curl keychain tmpreaper bash-completion \
        jq sox ffmpeg httrack python python3 golang libffi-dev python-pip python3-pip python-dev python3-dev libssl-dev dconf-cli scdaemon \
        pcscd

    sudo python3 -m pip install --upgrade pip
    sudo python3 -m pip install --upgrade ansible ipython

    sudo -E ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

    # set keyboard layout (with caps lock as esc)
    cat <<- EOF | sudo tee /etc/default/keyboard
        XKBMODEL="pc104"
        XKBLAYOUT="gb"
        XKBVARIANT=""
        XKBOPTIONS="caps:escape"
        BACKSPACE="guess"
EOF
    # apply temporarily, as above requires restart (I think)
    test $DISPLAY && setxkbmap -option "caps:escape" gb || true
fi

if [ $UBUNTU_DESKTOP ]; then
    # note i3-gaps may be used in future
    sudo -E apt-get -y install firefox i3 i3status dmenu
fi


# all platforms

# clone main repository to home
cd ~
test ! -d ~/dotfiles && git clone $ORIGIN
cd dotfiles
git pull --ff-only $ORIGIN master || true

# make sure the upstream for local master is remote master
git branch --set-upstream-to=origin/master master

# FZF -- install binary only. install script is expecting repo in ~/.fzf
test -d ~/.fzf/ && rm -rf ~/.fzf/
cp -a home/.fzf ~
# download binary but annoyingly create symlink in path (not configurable)
mkdir -p ~/.local/bin/
test -f ~/.local/bin/fzf && rm ~/.local/bin/fzf
~/.fzf/install --bin
# standard install location, already in $PATH. Remove symlink annoyingly
# created by fzf installer (if installer had ~/.local/bin in path) and copy actual binary
test -f ~/.local/bin/fzf && rm ~/.local/bin/fzf
mv ~/.fzf/bin/fzf ~/.local/bin/

# For Adobe source code pro (powershell patched)
./etc/powerline-patched/install.sh

# install dotfiles configuration
./install.sh
