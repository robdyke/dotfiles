#!/bin/bash
set -e

# curl -L https://github.com/naggie/dotfiles/raw/naggie/bootstrap.sh | bash

cat <<EOF
This script will install vim/git/tmux and then dotfiles.
Hit CTRL+C to abort in the next 3 seconds....

EOF

sleep 3


if [ $(uname) == 'Darwin' ]; then
    # macos
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install tmux vim git ssh
elif [ -f /etc/debian_version ]; then
    # debian/ubuntu
    sudo apt-get -y update
    # figlet is for server-splash
    sudo apt-get -y install tmux vim git ssh language-pack-en figlet
    sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
else
    echo "Unsupported OS."
    exit 2
fi

cd ~

# SSH key may or may not have been set up. If it has, use naggie branch. If not, master over HTTPS
git clone -b naggie git@github.com:naggie/dotfiles.git || git clone https://github.com/naggie/dotfiles.git

cd dotfiles
./install.sh

# start tmux (with reloaded shell)
tmux attach || tmux
