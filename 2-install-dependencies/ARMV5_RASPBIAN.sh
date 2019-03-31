#!/bin/bash
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

sudo -E apt-get -y update
sudo -E apt-get -y install tmux vim git tig zsh ssh pass httpie ncdu tree wget htop gnupg2 curl tmpreaper bash-completion jq
