apt-add-repository multiverse
apt-get -y update
apt-get -y install language-pack-en tmux vim git tig zsh ssh pass httpie ncdu tree wget htop gnupg2 curl tmpreaper bash-completion \
    jq sox ffmpeg httrack python python3 golang python-pip python3-pip libssl-dev dconf-cli scdaemon pcscd

# dstask
EXE="$(
    obtain \
        https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-amd64 \
        a8888a275ad8aa11121d45f589a22829707bd9c29ef0b19e747938c57fde313f
)"
cp "${EXE}" /usr/local/bin/dstask.new
chmod +x /usr/local/bin/dstask.new
mv /usr/local/bin/{dstask.new,dstask}

# ripgrep
TARGZ="$(
    obtain \
        https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz \
        c76080aa807a339b44139885d77d15ad60ab8cdd2c2fdaf345d0985625bc0f97
)"
[ -f /usr/local/bin/rg ] && rm -f /usr/local/bin/rg
tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" ripgrep-0.10.0-x86_64-unknown-linux-musl/rg

# FZF
TARGZ="$(
    obtain \
        https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_amd64.tgz \
        3020c7d4d43d524ff394df306337b6de873b9db0bd9cd9dc73cd80cbd6e0c2f8
)"
[ -f /usr/local/bin/fzf ] && rm -f /usr/local/bin/fzf
tar -C /usr/local/bin -xzf "$TARGZ"

# neovim (don't write directly, swap atomically so running nvim won't block)
BIN="$(
    obtain \
        https://github.com/neovim/neovim/releases/download/v0.3.3/nvim.appimage \
        6c937c0a2b37e4ad99bae2f37f461ae47a590e62bddecf903b0b5bafe0eaaadb
)"
cp "${EXE}" /usr/local/bin/nvim.new
chmod +x /usr/local/bin/nvim.new
mv /usr/local/bin/{nvim.new,nvim}

# ubuntu desktop specific (soon to be removed in favor of arch)
if dpkg -l | grep -vq landscape; then
    apt-get -y install firefox i3 i3status dmenu xautolock powertop

    # stop default screensaver (xubuntu) -- note xsettings are also required
    apt-get -y purge light-locker xfce4-power-manager

    # ykman only available in later versions of ubuntu. Install if available.
    apt-get -y install yubikey-manager || true

    # alacritty
    TARGZ="$(
        obtain \
            https://github.com/jwilm/alacritty/releases/download/v0.2.4/Alacritty-v0.2.4-x86_64.tar.gz \
            1de78461e75527161f95b20406302baf4975d98ee9113af7cdf23a63aa0f05b1
    )"
    tar -C /usr/local/bin/ -xzf "$TARGZ"

    # browserpass host
    ZIP="$(
        obtain \
            https://github.com/browserpass/browserpass/releases/download/2.0.22/browserpass-linux64.zip \
            1753e1ca37045eb2eaa3b3b1a5d7a6ecdc1746e301c275bbc38e9617f50ccb39
    )"
    unzip -p "$ZIP" browserpass-linux64 | dd of=/usr/local/bin/browserpass.new
    chmod +x /usr/local/bin/browserpass.new
    mv /usr/local/bin/{browserpass.new,browserpass}
fi
