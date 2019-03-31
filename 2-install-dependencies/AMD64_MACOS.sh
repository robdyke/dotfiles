#!/bin/bash
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

# dstask
download_to_cache_dir https://github.com/naggie/dstask/releases/download/v0.8/dstask-darwin-amd64 08239f5cd9f56053e3b0ddc09d0e2b1b40083964810edd22161c25c6e09f12b8
chmod +x "${CACHE_DIR}/dstask-darwin-amd64"
sudo mv "${CACHE_DIR}/dstask-darwin-amd64" /usr/local/bin/dstask
