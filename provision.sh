#!/bin/bash
# This script installs global dependencies and executables required by dotfiles, and then the configuration files with ./install.sh

ORIGIN=https://github.com/naggie/dotfiles.git

# Installation: No PPAs.
# Native package manager or local checksummed appimage/exe (.local/bin) (from
# tar if necessary). No magic scripts, except homebrew.

# Note that tar commands, reading from stdin are quite brittle. Removing or
# adding a - prefix to the flags will break things.

# local or global? same for pip with install --user

# Essential:
# * vim/neovim
# * tmux
# * ripgrep
# * FZF
# * Task
# * Pass
# * Bash/zsh

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


# for local installs, added to PATH with env.sh
mkdir -p ~/.local/bin

if [ $MACOS_DESKTOP ]; then
    if [ ! -f /usr/local/bin/brew ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi

    # recommended, uses /Applications now.
    brew tap caskroom/homebrew-cask
    brew cask install spectacle firefox alacritty

    # flux is no longer required -- night shift!

    # Upgrade or install (logic necessary)
    packages=(tmux vim git tig httpie ncdu tree bash pass zsh openssh jq wget task htop gnupg2 bash-completion keychain iproute2mac tmpreaper \
        coreutils sox ffmpeg httrack python ripgrep python go nvim fzf)
    for package in "${packages[@]}"; do
        brew upgrade $package || brew install $package
    done

    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade ansible ipython

    # correct so alias works cross platform
    ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

    sudo chsh -s /usr/local/bin/bash -u $(whoami)
fi

if [ $UBUNTU ]; then
    sudo -E apt-add-repository multiverse
    sudo -E apt-get -y update
    sudo -E apt-get -y install language-pack-en curl

    # ripgrep
    curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz \
        | tar -C ~/.local/bin --strip=1 -xzf - ripgrep-0.10.0-x86_64-unknown-linux-musl/rg

    if ! sha256sum ~/.local/bin/rg | grep -q 6a618aa3ae055866e99ea633079e8eff8623bdfe3209fe3bddf20bd4451b2b08; then
        chmod -x ~/.local/bin/rg
        echo "Corrupt or compromised rg binary detected! See ~/.local/bin/"
        exit 4
    fi

    # FZF
    curl -L https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_amd64.tgz \
        | tar xzf - -C ~/.local/bin

    if ! sha256sum ~/.local/bin/fzf | grep -q 8ddd8339b522fed766d45688432d74cdf4ecae384417d39be326ed24565b20ce; then
        chmod -x ~/.local/bin/fzf
        echo "Corrupt or compromised fzf binary detected! See ~/.local/bin/"
        exit 4
    fi

    # alacritty
    curl -L https://github.com/jwilm/alacritty/releases/download/v0.2.3/Alacritty-v0.2.3-x86_64.tar.gz \
        | tar xzf - -C ~/.local/bin

    if ! sha256sum ~/.local/bin/alacritty | grep -q e0d913e422dce0674061ad412c0cd1dfd50eb069b436433a03cf96e85bb4720f; then
        chmod -x ~/.local/bin/alacritty
        echo "Corrupt or compromised alacritty binary detected! See ~/.local/bin/"
        exit 4
    fi

    # neovim (don't write directly, swap atomically so running nvim won't block)
    curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage > ~/.local/bin/nvim.new
    chmod +x ~/.local/bin/nvim.new

    if ! sha256sum ~/.local/bin/nvim.new | grep -q 5f34d714eebbd45489f3628bc96f2aee72077b794f7510fdeb6883a78b18032b; then
        chmod -x ~/.local/bin/nvim.new
        echo "Corrupt or compromised nvim binary detected! See ~/.local/bin/nvim.new"
        exit 4
    fi

    mv ~/.local/bin/nvim.new ~/.local/bin/nvim
fi

if [ $RASPBIAN ]; then
    # ripgrep
    curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz \
        | tar -C ~/.local/bin --strip=1 -xzf - ripgrep-0.10.0-arm-unknown-linux-gnueabihf/rg

    if ! sha256sum ~/.local/bin/rg | grep -q 17825561dddf366fc86bcde47e0ba35ab47b03145405174ebde697cb446e041f; then
        chmod -x ~/.local/bin/rg
        echo "Corrupt or compromised rg binary detected! See ~/.local/bin/"
        exit 4
    fi

    # FZF
    curl -L https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_arm5.tgz \
        | tar -C ~/.local/bin --strip=1 -xzf - fzf

    if ! sha256sum ~/.local/bin/fzf | grep -q 6113f87573163cd711e29244992b5321424f9ac8ecf57f2ae6a98d738d5361a4; then
        chmod -x ~/.local/bin/fzf
        echo "Corrupt or compromised fzf binary detected! See ~/.local/bin/"
        exit 4
    fi
fi

if [ $UBUNTU ] || [ $RASPBIAN ]; then
    sudo -E apt-get -y update
    sudo -E apt-get -y install tmux vim git tig zsh ssh pass figlet httpie ncdu tree wget htop gnupg2 curl keychain tmpreaper bash-completion \
        jq sox ffmpeg httrack python python3 golang libffi-dev python-pip python3-pip python-dev python3-dev libssl-dev dconf-cli scdaemon \
        pcscd rxvt-unicode-256color

    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user --upgrade ansible ipython

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

# install dotfiles configuration
./install.sh
