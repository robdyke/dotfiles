#!/bin/bash
set -ex
source include/util.sh
assert_root()

# ripgrep
TARGZ="$(
    obtain \
        https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz \
        5909eb4246f8e4936a2d09d0b38c647733578f78f6aa5ace49027c1b7c4bf0e1
)"
[ -f /usr/local/bin/rg ] && rm -f /usr/local/bin/rg
tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" ripgrep-0.10.0-arm-unknown-linux-gnueabihf/rg

# FZF
TARGZ="$(
    obtain \
        https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_arm5.tgz \
        aa5f46c21fb765a20494fdcb00b86b6bde3b29538f25d49398f3b423f8e1e394
)"
[ -f /usr/local/bin/fzf ] && rm -f /usr/local/bin/fzf
tar -C /usr/local/bin/ -xzf "$TARGZ"

apt-get -y update
apt-get -y install tmux vim git tig zsh ssh pass httpie ncdu tree wget htop gnupg2 curl tmpreaper bash-completion jq
