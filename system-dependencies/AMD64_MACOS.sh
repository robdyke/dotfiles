if [ ! -f /usr/local/bin/brew ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

# recommended, uses /Applications now.
brew tap caskroom/homebrew-cask
brew cask install spectacle firefox alacritty

# flux is no longer required -- night shift!

# resolve possible coreutils conflict
brew unlink md5sha1sum

# Upgrade or install (logic necessary)
packages=(tmux vim git tig httpie ncdu tree bash pass zsh openssh jq wget htop gnupg2 bash-completion iproute2mac tmpreaper coreutils sox \
    ffmpeg httrack ripgrep nvim fzf pinentry-mac ykman)
for package in "${packages[@]}"; do
    brew upgrade $package || brew install $package
done

# create alias for gsha256sum
ln -sf /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# dstask
EXE="$(
    obtain \
        https://github.com/naggie/dstask/releases/download/v0.8/dstask-darwin-amd64 \
        08239f5cd9f56053e3b0ddc09d0e2b1b40083964810edd22161c25c6e09f12b8
)"
cp "${EXE}" /usr/local/bin/dstask.new
chmod +x /usr/local/bin/dstask.new
mv -f /usr/local/bin/{dstask.new,dstask}

# browserpass host
ZIP="$(
    obtain \
        https://github.com/browserpass/browserpass-native/releases/download/3.0.6/browserpass-darwin64-3.0.6.tar.gz \
        422bc6dd1270a877af6ac7801a75b4c4b57171d675c071470f31bc24196701e3
)"
unzip -p "$ZIP" browserpass-darwin64 | sudo dd of=/usr/local/bin/browserpass.new
sudo chmod +x /usr/local/bin/browserpass.new
sudo mv -f /usr/local/bin/{browserpass.new,browserpass}
