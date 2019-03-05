#!/bin/bash
# This script installs global dependencies and executables required by dotfiles, and then the configuration files with ./install.sh

ORIGIN=https://github.com/naggie/dotfiles.git

# Installation method preference:

# 1. Native package manager
# 2. Native checksummed binary (via download_to_cache_dir)
# 3. Ad-hoc checksummed binary install from tarball
# 4. Ad-hoc checksummed install from source

# global install preferred

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
function download_to_cache_dir {
    URL="$1"
    SHA256SUM="$2"

    FILENAME="$(echo $URL | rev | cut -d / -f 1 | rev)"
    TARGET="${CACHE_DIR}/${FILENAME}"

    if [ ! -f "$TARGET" ] || ! sha256sum $TARGET | grep -q $SHA256SUM; then
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
mkdir -p $CACHE_DIR
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
    brew tap dustinwilson/tap   # TODO replace with checksummed binary
    brew tap caskroom/homebrew-cask
    brew cask install spectacle firefox alacritty

    # flux is no longer required -- night shift!

    # Upgrade or install (logic necessary)
    packages=(tmux vim git tig httpie ncdu tree bash pass zsh openssh jq wget htop gnupg2 bash-completion keychain iproute2mac tmpreaper \
        coreutils sox ffmpeg httrack python ripgrep python go nvim fzf pinentry-mac ykman browserpass)
    for package in "${packages[@]}"; do
        brew upgrade $package || brew install $package
    done

    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade ansible ipython

    # dstask
    download_to_cache_dir https://github.com/naggie/dstask/releases/download/v0.8/dstask-darwin-amd64 08239f5cd9f56053e3b0ddc09d0e2b1b40083964810edd22161c25c6e09f12b8
    chmod +x "${CACHE_DIR}/dstask-darwin-amd64"
    sudo mv "${CACHE_DIR}/dstask-darwin-amd64" /usr/local/bin/dstask

    # correct so alias works cross platform
    ln -sf /usr/local/bin/gpg /usr/local/bin/gpg2

    sudo chsh -s /usr/local/bin/bash $(whoami)

    browserpass-setup firefox
fi

if [ $UBUNTU ]; then
    sudo -E apt-add-repository multiverse
    sudo -E apt-get -y update
    sudo -E apt-get -y install language-pack-en curl

    # dstask
    download_to_cache_dir https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-amd64 a8888a275ad8aa11121d45f589a22829707bd9c29ef0b19e747938c57fde313f
    chmod +x "${CACHE_DIR}/dstask-linux-amd64"
    sudo mv "${CACHE_DIR}/dstask-linux-amd64" /usr/local/bin/dstask

    # ripgrep
    download_to_cache_dir https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz c76080aa807a339b44139885d77d15ad60ab8cdd2c2fdaf345d0985625bc0f97
    sudo tar -C "${BIN_DIR}" --strip=1 -xzf "${CACHE_DIR}/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz" ripgrep-0.10.0-x86_64-unknown-linux-musl/rg

    # FZF
    download_to_cache_dir https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_amd64.tgz 3020c7d4d43d524ff394df306337b6de873b9db0bd9cd9dc73cd80cbd6e0c2f8
    sudo tar -C "$BIN_DIR" -xzf "${CACHE_DIR}/fzf-0.17.5-linux_amd64.tgz"

    # neovim (don't write directly, swap atomically so running nvim won't block)
    download_to_cache_dir https://github.com/neovim/neovim/releases/download/v0.3.3/nvim.appimage 6c937c0a2b37e4ad99bae2f37f461ae47a590e62bddecf903b0b5bafe0eaaadb
    chmod +x "${CACHE_DIR}/nvim.appimage"
    # copy to preserve cache
    sudo cp "${CACHE_DIR}/nvim.appimage" "${BIN_DIR}/nvim"
fi

if [ $RASPBIAN ]; then
    # dstask
    download_to_cache_dir https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-arm5 96da57e91945c9d87c478c04fe65c32d6881c77e06ea3ffa2437d3a563246021
    chmod +x "${CACHE_DIR}/dstask-linux-arm5"
    sudo mv "${CACHE_DIR}/dstask-linux-arm5" /usr/local/bin/dstask

    # ripgrep
    download_to_cache_dir https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz 5909eb4246f8e4936a2d09d0b38c647733578f78f6aa5ace49027c1b7c4bf0e1
    sudo tar -C $BIN_DIR --strip=1 -xzf "${CACHE_DIR}/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz" ripgrep-0.10.0-arm-unknown-linux-gnueabihf/rg

    # FZF
    download_to_cache_dir https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_arm5.tgz aa5f46c21fb765a20494fdcb00b86b6bde3b29538f25d49398f3b423f8e1e394
    sudo tar -C $BIN_DIR -xzf "${CACHE_DIR}/fzf-0.17.5-linux_arm5.tgz"
fi

if [ $UBUNTU ] || [ $RASPBIAN ]; then
    sudo -E apt-get -y update
    sudo -E apt-get -y install tmux vim git tig zsh ssh pass httpie ncdu tree wget htop gnupg2 curl keychain tmpreaper bash-completion \
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
    sudo -E apt-get -y install firefox i3 i3status dmenu xautolock yubikey-manager
    # stop default screensaver (xubuntu) -- note xsettings are also required
    sudo -E apt-get -y purge light-locker xfce4-power-manager

    # alacritty
    download_to_cache_dir https://github.com/jwilm/alacritty/releases/download/v0.2.4/Alacritty-v0.2.4-x86_64.tar.gz 1de78461e75527161f95b20406302baf4975d98ee9113af7cdf23a63aa0f05b1
    sudo tar -C $BIN_DIR -xzf "${CACHE_DIR}/Alacritty-v0.2.4-x86_64.tar.gz"

    # browserpass host
    download_to_cache_dir https://github.com/browserpass/browserpass/releases/download/2.0.22/browserpass-linux64.zip 1753e1ca37045eb2eaa3b3b1a5d7a6ecdc1746e301c275bbc38e9617f50ccb39
    unzip -p "${CACHE_DIR}/browserpass-linux64.zip" browserpass-linux64 | sudo dd of=$BIN_DIR/browserpass.tmp
    sudo chmod +x $BIN_DIR/browserpass.tmp
    sudo mv $BIN_DIR/browserpass.tmp $BIN_DIR/browserpass
    mkdir -p ~/.mozilla/native-messaging-hosts
    cp etc/firefox/com.dannyvankooten.browserpass.json ~/.mozilla/native-messaging-hosts/
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
