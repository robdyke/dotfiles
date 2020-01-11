#!/bin/bash

# This script should be run as the target user. It uses sudo where appropriate.

# See README.md for "Mode of operation" for an explanation of what this script does.
ORIGIN=https://github.com/naggie/dotfiles.git

# exit on error
set -Eeo pipefail

# Supportted platforms. For more specific stuff, such as extra packages for
# desktop vs server or version specific stuff, put that logic in the platform
# specific install-dependencies script.
ARCH_AMD64=ARCH_AMD64
MACOS_AMD64=MACOS_AMD64
UBUNTU_AMD64=UBUNTU_AMD64
KUBUNTU_AMD64=KUBUNTU_AMD64
ELEMENTARYOS_AMD64=ELEMENTARYOS_AMD64
FEDORA_AMD64=FEDORA_AMD64
RASPBIAN_ARMV5=RASPBIAN_ARMV5

# authorise sudo early on
echo "Please enter sudo password. Sudo session will be kept alive until this script exits."
# sudo -v is technically correct but asks for a non-existent password on fresh AWS Ubuntu AMIs
sudo echo -n

# sudo keepalive. This will keep the sudo watchdog fed until this script exits.
# This works buy poking the parent process to see if it's still alive.
while true; do sudo -n true; sleep 15; kill -0 "$$" || exit; done 2>/dev/null &


function get_platform() {
    if uname | grep -q Linux; then
        HOSTNAMECTL=$(sudo hostnamectl)

        if [ -z "$HOSTNAMECTL" ]; then
            >&2 echo "Could not determine OS"
            exit 1
        fi

        LONG_BIT=$(getconf LONG_BIT)
        if [[ $HOSTNAMECTL == *"Arch "* ]] && [[ $LONG_BIT == 64 ]]; then
            echo $ARCH_AMD64
        elif [[ $HOSTNAMECTL == *Ubuntu* ]] && [[ $LONG_BIT == 64 ]]; then
            echo $UBUNTU_AMD64
        elif [[ $HOSTNAMECTL == *Kubuntu* ]] && [[ $LONG_BIT == 64 ]]; then
            echo $KUBUNTU_AMD64
        elif [[ $HOSTNAMECTL == *elementary* ]] && [[ $LONG_BIT == 64 ]]; then
            echo $ELEMENTARYOS_AMD64
        elif [[ $HOSTNAMECTL == *Fedora* ]] && [[ $LONG_BIT == 64 ]]; then
            echo $FEDORA_AMD64
        elif [[ $HOSTNAMECTL == *Raspbian* ]] && [[ $LONG_BIT == 32 ]]; then
            echo $RASPBIAN_ARMV5
        else
            >&2 echo "Unsupported OS"
            exit 1
        fi
    elif uname | grep -q Darwin && getconf LONG_BIT | grep -q 64; then
        echo $MACOS_AMD64
    else
        >&2 echo "Unsupported OS"
        exit 1
    fi
}


PLATFORM=$(get_platform)

# make sure git/sudo is installed
case $PLATFORM in
    $ARCH_AMD64)
        # try to install sudo if necessary and possible
        if ! which sudo; then
            if [ $(id -u) = 0 ]; then
                pacman -Sy --noconfirm sudo
            else
                >&2 echo "Could not bootstrap, sudo command not available / not running as root"
                exit 1
            fi
        fi

        sudo pacman -Sy --noconfirm git
        ;;
    $MACOS_AMD64)
        # triggers install of xcode cli tools or effectively does nothing
        git --version
        ;;
    $UBUNTU_AMD64)
        sudo apt-get -y install git
        ;;
    $ELEMENTARYOS_AMD64)
        sudo apt-get -y install git
        ;;
    $FEDORA_AMD64)
        sudo dnf -y install git
        ;;
    $RASPBIAN_ARMV5)
        sudo apt-get -y install git
        ;;
esac

# clone main repository to home and change to it
test ! -d ~/dotfiles && git clone $ORIGIN ~/dotfiles
cd ~/dotfiles
git pull --ff-only $ORIGIN master || true
git branch --set-upstream-to=origin/master master

# contains utilities for downloading and installation
source system-dependencies/include/util.sh

# adhoc program installers
source system-dependencies/include/adhoc.sh

# system-dependencies (run by root)
source system-dependencies/${PLATFORM}.sh

# system-configuration (run by root)
source system-configuration/${PLATFORM}.sh

# user-configuration (run by current user)
if [[ $(whoami) == naggie ]]; then
    ./user-configuration-naggie.sh
else
    ./user-configuration.sh
fi
