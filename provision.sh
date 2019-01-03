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
# * dstask
# * pass
# * bash/zsh
# * gnupg2

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

# download file if it doesn't exist, then check the sha256sum matches to
# mitigate forward-looking supply chain attacks. Exit script on fail.
function download {
    URL="$1"
    SHA256SUM="$2"
    DIR="$3"

    FILENAME="$(echo $URL | rev | cut -d / -f 1 | rev)"
    TARGET="${DIR}/${FILENAME}"

    if [ ! -f "$TARGET" ]; then
        curl -L "$URL" > "$TARGET"
    fi

    if ! sha256sum $TARGET | grep -q $SHA256SUM; then
        echo "Corrupt or compromised download detected! See $TARGET"
        exit 4
    fi
}


# where to install bare EXEs (or softare compile from src)
BIN_DIR=/usr/local/bin
CACHE_DIR=~/.cache/dotfiles
mkdir -p $CACHE
# for local installs -- scripts, added to PATH with env.sh
mkdir -p ~/.local/bin
mkdir -p ~/.local/src

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
    packages=(tmux vim git tig httpie ncdu tree bash pass zsh openssh jq wget htop gnupg2 bash-completion keychain iproute2mac tmpreaper \
        coreutils sox ffmpeg httrack python ripgrep python go nvim fzf pinentry-mac)
    for package in "${packages[@]}"; do
        brew upgrade $package || brew install $package
    done

    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade ansible ipython

    # dstask
    download https://github.com/naggie/dstask/releases/download/v0.4/dstask-darwin-amd64 \
        23368590480ba587b9b8fce5af06672ddb643c606de20e9850886d474b5604c7 \
        "${CACHE_DIR}"

    mv "${CACHE_DIR}/dstask-darwin-amd64" /usr/local/bin/
    chmod +x /usr/local/bin/dstask

    # correct so alias works cross platform
    ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

    sudo chsh -s /usr/local/bin/bash $(whoami)
fi

if [ $UBUNTU ]; then
    sudo -E apt-add-repository multiverse
    sudo -E apt-get -y update
    sudo -E apt-get -y install language-pack-en curl

    # dstask
    download https://github.com/naggie/dstask/releases/download/v0.4/dstask-linux-amd64 \
        6b62fd7d1982c088f5303bc0b967197003d2c0a878017e2eccad35d8ef8cb852 \
        "${CACHE_DIR}"

    mv "${CACHE_DIR}/dstask-linux-amd64" /usr/local/bin/
    chmod +x /usr/local/bin/dstask

    # ripgrep
    download https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz \
        c76080aa807a339b44139885d77d15ad60ab8cdd2c2fdaf345d0985625bc0f97 \
        "$CACHE_DIR"

    tar -C "${BIN_DIR}" --strip=1 -xzf "${CACHE_DIR}/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz" ripgrep-0.10.0-x86_64-unknown-linux-musl/rg

    # FZF
    download https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_amd64.tgz \
        3020c7d4d43d524ff394df306337b6de873b9db0bd9cd9dc73cd80cbd6e0c2f8  \
        "$CACHE_DIR"

    tar -C "$BIN_DIR" xzf "${CACHE_DIR}/fzf-0.17.5-linux_amd64.tgz"


    # alacritty
    curl -L https://github.com/jwilm/alacritty/releases/download/v0.2.3/Alacritty-v0.2.3-x86_64.tar.gz \
        | tar xzf - -C $PREFIX

    if ! sha256sum $PREFIX/alacritty | grep -q e0d913e422dce0674061ad412c0cd1dfd50eb069b436433a03cf96e85bb4720f; then
        chmod -x $PREFIX/alacritty
        echo "Corrupt or compromised alacritty binary detected! See $PREFIX/"
        exit 4
    fi

    # neovim (don't write directly, swap atomically so running nvim won't block)
    curl -L https://github.com/neovim/neovim/releases/download/v0.3.1/nvim.appimage > $PREFIX/nvim.new
    chmod +x $PREFIX/nvim.new

    if ! sha256sum $PREFIX/nvim.new | grep -q ade95e2e2ba025827151c322bf28814f52260dbeafba7cf185d46511eceedbe9; then
        chmod -x $PREFIX/nvim.new
        echo "Corrupt or compromised nvim binary detected! See $PREFIX/nvim.new"
        exit 4
    fi

    mv $PREFIX/nvim.new $PREFIX/nvim
fi

if [ $RASPBIAN ]; then
    # dstask
    download https://github.com/naggie/dstask/releases/download/v0.4/dstask-linux-arm7 \
        4797fb280b29111f91979e3a711de26f32170ec96713ed8d111f0957d13f49f6 \
        "${CACHE_DIR}"

    mv "${CACHE_DIR}/dstask-linux-arm7" /usr/local/bin/
    chmod +x /usr/local/bin/dstask

    # ripgrep
    curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz \
        | tar -C $PREFIX --strip=1 -xzf - ripgrep-0.10.0-arm-unknown-linux-gnueabihf/rg

    if ! sha256sum $PREFIX/rg | grep -q 17825561dddf366fc86bcde47e0ba35ab47b03145405174ebde697cb446e041f; then
        chmod -x $PREFIX/rg
        echo "Corrupt or compromised rg binary detected! See $PREFIX/"
        exit 4
    fi

    # FZF
    curl -L https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_arm5.tgz \
        | tar -C $PREFIX --strip=1 -xzf - fzf

    if ! sha256sum $PREFIX/fzf | grep -q 6113f87573163cd711e29244992b5321424f9ac8ecf57f2ae6a98d738d5361a4; then
        chmod -x $PREFIX/fzf
        echo "Corrupt or compromised fzf binary detected! See $PREFIX/"
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
    sudo -E apt-get -y install firefox i3 i3status dmenu xautolock
    # stop default screensaver (xubuntu) -- note xsettings are also required
    sudo -E apt-get -y purge light-locker xfce4-power-manager
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
if [[ $(whoami) == naggie ]]; then
    ./install-naggie.sh
else
    ./install.sh
fi
