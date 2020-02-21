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

# stop typos from causing annoying install prompt
sudo dnf remove -y PackageKit-command-not-found

adhoc_dstask_linux_amd64
adhoc_golang_linux_amd64
adhoc_hugo_linux_amd64
adhoc_ffsend_linux_amd64

# desktop only
if hostnamectl | grep -q Workstation; then
    adhoc_alacritty_linux_amd64
    adhoc_browserpass_linux_amd64
    adhoc_cura_linux_amd64

    sudo dnf install -y \
        kicad \
        kicad-packages3d \
        openscad
fi
