sudo dnf upgrade -y
sudo dnf install -y \
    @development-tools \
    bash-completion \
    curl \
    dnf \
    etckeeper \
    fzf \
    git \
    git-subtree \
    gnupg2 \
    htop \
    httpie \
    httrack \
    hub \
    jq \
    ncdu \
    neovim \
    opensc \
    openscad \
    parallel \
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
    upx \
    vim \
    wget \
    yubikey-manager \
    zsh \

adhoc_dstask_linux_amd64
adhoc_golang_linux_amd64

# desktop only
if hostnamectl | grep -q Workstation; then
    adhoc_alacritty_linux_amd64
    adhoc_browserpass_linux_amd64
fi
