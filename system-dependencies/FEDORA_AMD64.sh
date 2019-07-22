sudo dnf -y upgrade --refresh
sudo dnf -y install tmux vim git tig zsh pass httpie ncdu tree wget htop gnupg2 curl bash-completion jq sox httrack python python3 golang python-pip python3-pip fzf ripgrep neovim opensc etckeeper

# dstask
EXE="$(
    obtain \
        https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-amd64 \
        a8888a275ad8aa11121d45f589a22829707bd9c29ef0b19e747938c57fde313f
)"
sudo cp "${EXE}" /usr/local/bin/dstask.new
sudo chmod +x /usr/local/bin/dstask.new
sudo mv -f /usr/local/bin/{dstask.new,dstask}
