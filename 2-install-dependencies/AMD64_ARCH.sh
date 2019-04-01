#!/bin/bash
set -ex
source include/util.sh

# dstask
EXE="$(
    obtain \
        https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-amd64 \
        a8888a275ad8aa11121d45f589a22829707bd9c29ef0b19e747938c57fde313f
)"
sudo cp "${EXE}" /usr/local/bin/dstask.new
sudo chmod +x /usr/local/bin/dstask.new
sudo mv /usr/local/bin/{dstask.new,dstask}

sudo pacman -S git tmux vim tig zsh ssh pass httpie ncdu tree wget htop gnupg2 curl tmpreaper bash-completion jq sox ffmpeg httrack python \
    python3 golang

# TODO yubikey stuff
