#!/bin/bash
set -e

# curl -sL https://github.com/naggie/dotfiles/raw/naggie/bootstrap.sh | bash && bash

cat <<EOF
This script will install vim/git/tmux and then dotfiles, trusting github public key.
Hit CTRL+C to abort in the next 3 seconds....

EOF

sleep 3


if [ ! -d ~/.ssh ]; then
    mkdir ~/.ssh
    chmod 700 ~/.ssh
fi

touch ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts

grep -q github.com ~/.ssh/known_hosts || cat <<EOF >> ~/.ssh/known_hosts
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF

if [ $(uname) == 'Darwin' ]; then
    # macos
    if [ ! -f /usr/local/bin/brew ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi

    packages=(tmux vim git httpie ncdu tree bash)
    for package in "${packages[@]}"; do
        brew upgrade $package || brew install $package
    done

elif grep -q Ubuntu /etc/issue; then
    sudo apt-add-repository multiverse
    sudo apt-get -y update
    # figlet is for server-splash
    sudo apt-get -y install tmux vim git ssh language-pack-en figlet httpie ncdu tree
    sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
elif grep -q Raspbian /etc/issue; then
    sudo apt-get -y update
    # Raspbian is British, locale is already correct. language-pack-en isn't a package.
    # figlet is for server-splash
    sudo apt-get -y install tmux vim git ssh figlet httpie ncdu tree
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
