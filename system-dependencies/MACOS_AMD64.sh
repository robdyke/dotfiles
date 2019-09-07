if [ ! -f /usr/local/bin/brew ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

# recommended, uses /Applications now.
brew tap caskroom/homebrew-cask
brew cask install spectacle firefox alacritty mtmr

# flux is no longer required -- night shift!

# resolve possible coreutils conflict
brew unlink md5sha1sum

# Upgrade or install (logic necessary)
packages=(
    bash
    bash-completion
    coreutils
    ffmpeg
    fzf
    git
    gnupg2
    htop
    httpie
    httrack
    hub
    iproute2mac
    jq
    ncdu
    nvim
    openssh
    pass
    pinentry-mac
    ripgrep
    sox
    tig
    tmpreaper
    tmux
    tree
    upx
    vim
    wget
    ykman
    zsh
)

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
TARGZ="$(
    obtain \
        https://github.com/browserpass/browserpass-native/releases/download/3.0.6/browserpass-darwin64-3.0.6.tar.gz \
        422bc6dd1270a877af6ac7801a75b4c4b57171d675c071470f31bc24196701e3
)"
[ -f /usr/local/bin/browserpass ] && sudo rm -f /usr/local/bin/browserpass
sudo tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" browserpass-darwin64-3.0.6/browserpass-darwin64
sudo mv /usr/local/bin/browserpass-darwin64 /usr/local/bin/browserpass
