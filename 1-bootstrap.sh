#!/bin/bash

# See README.md for "Mode of operation" for an explanation of what this script does.
ORIGIN=https://github.com/naggie/dotfiles.git
set -e
set -x


# Supportted platforms. For more specific stuff, such as extra packages for
# desktop vs server or version specific stuff, put that logic in the platform
# specific install-dependencies script.
AMD64_ARCH=AMD64_ARCH
AMD64_MACOS=AMD64_MACOS
AMD64_UBUNTU=AMD64_UBUNTU
ARMV5_RASPBIAN=ARMV5_RASPBIAN


function get_platform() {
    if uname | grep -q Linux; then
        if grep -q Arch /etc/issue && getconf LONG_BIT | grep -q 64; then
            echo $AMD64_ARCH
        elif grep -q Ubuntu /etc/issue && getconf LONG_BIT | grep -q 64; then
            echo $AMD64_UBUNTU
        elif grep -q Raspbian /etc/issue && getconf LONG_BIT | grep -q 32; then
            echo $ARMV5_RASPBIAN
        else
            >&2 echo "Unsupported OS"
        fi
    elif uname | grep -q Darwin && getconf LONG_BIT | grep -q 64; then
        echo $AMD64_MACOS
    else
        >&2 echo "Unsupported OS"
    fi
}


PLATFORM=$(get_platform)

# make sure git is installed
case $PLATFORM in
    $AMD64_ARCH)
        sudo pacman -S git
        ;;
    $AMD64_MACOS)
        # triggers install of xcode cli tools or effectively does nothing
        git --version
        ;;
    $AMD64_UBUNTU)
        sudo apt-get install git
        ;;
    $ARMV5_RASPBIAN)
        sudo apt-get install git
        ;;
esac

# clone main repository to home and change to it
test ! -d ~/dotfiles && git clone $ORIGIN ~/dotfiles
cd ~/dotfiles
git pull --ff-only $ORIGIN master || true
git branch --set-upstream-to=origin/master master

# 2-install-dependencies
pushd 2-install-dependencies
    ./${PLATFORM}.sh
popd

# 3-system-configuration
pushd 3-system-configuration
    ./${PLATFORM}.sh
popd

# 4-user-configuration
if [[ $(whoami) == naggie ]]; then
    ./4-user-configuration-naggie.sh
else
    ./4-user-configuration.sh
fi
