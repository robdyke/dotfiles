# dstask
EXE="$(
    obtain \
        https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-amd64 \
        a8888a275ad8aa11121d45f589a22829707bd9c29ef0b19e747938c57fde313f
)"
sudo cp "${EXE}" /usr/local/bin/dstask.new
sudo chmod +x /usr/local/bin/dstask.new
sudo mv -f /usr/local/bin/{dstask.new,dstask}

sudo pacman --noconfirm -Sy git tmux vim tig zsh openssh pass httpie ncdu tree wget htop gnupg curl bash-completion jq sox ffmpeg httrack \
    python go


# TODO yubikey stuff
# TODO tmpreaper
