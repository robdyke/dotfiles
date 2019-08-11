sudo dnf -y upgrade --refresh \
    bash-completion \
    curl \
    dnf \
    etckeeper \
    fzf \
    git \
    gnupg2 \
    golang \
    htop \
    httpie \
    httrack \
    install \
    jq \
    ncdu \
    neovim \
    opensc \
    pass \
    python \
    python-pip \
    python3 \
    python3-pip \
    ripgrep \
    sox \
    sudo \
    tig \
    tmux \
    tree \
    vim \
    wget \
    zsh \

# dstask
EXE="$(
    obtain \
        https://github.com/naggie/dstask/releases/download/v0.8/dstask-linux-amd64 \
        a8888a275ad8aa11121d45f589a22829707bd9c29ef0b19e747938c57fde313f
)"
sudo cp "${EXE}" /usr/local/bin/dstask.new
sudo chmod +x /usr/local/bin/dstask.new
sudo mv -f /usr/local/bin/{dstask.new,dstask}
