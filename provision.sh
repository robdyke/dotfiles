#!/bin/bash
# This script installs global dependencies and executables required by dotfiles, and then the configuration files with ./install.sh

ORIGIN=https://github.com/naggie/dotfiles.git

# Installation: No PPAs.
# Native package manager or local checksummed appimage/exe (.local/bin) (from
# tar if necessary). No magic scripts, except homebrew.

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
        | tar -C ~/.local/bin --strip=1 -xzf - fzf

    if ! sha256sum ~/.local/bin/fzf | grep -q 8ddd8339b522fed766d45688432d74cdf4ecae384417d39be326ed24565b20ce; then
        chmod -x ~/.local/bin/fzf
        echo "Corrupt or compromised fzf binary detected! See ~/.local/bin/"
        exit 4
    fi

    # alacritty -- onyl binary available is deb
    ALACRITTY_DEB_FILE="$(mktemp --suffix=.deb)"
    curl -L "https://github.com/jwilm/alacritty/releases/download/v0.2.3/Alacritty-v0.2.3_amd64.deb" > "$ALACRITTY_DEB_FILE"
    if ! sha256sum "$ALACRITTY_DEB_FILE" | grep -q 184f3ed80c70fe9c73f486178fc1d72d2c968998b0ac69c9fd8a9f676447f188; then
        echo "Corrupt or compromised Alacritty deb detected! See $ALACRITTY_DEB_FILE"
        exit 4
    fi
    sudo dpkg -i "$ALACRITTY_DEB_FILE"
    rm "$ALACRITTY_DEB_FILE"
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

    if ! sha256sum ~/.local/bin/fzf | grep -q 65d4f3fd9af4449f1608eb3b0e91c8bc2617b9630b9c3e10b3e3040955025083; then
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
