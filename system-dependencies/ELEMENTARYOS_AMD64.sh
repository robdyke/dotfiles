# tmpreaper tries to do a post-install "configuration" screen to warn the user.
export DEBIAN_FRONTEND=noninteractive

sudo -E apt-get -y update
sudo -E apt-get install -y software-properties-common
# -E is necessary for DEBIAN_FRONTEND
sudo -E apt-add-repository --yes multiverse
sudo -E apt-get -y update
sudo -E apt-get -y upgrade
sudo -E apt-get -y install \
    bash-completion \
    curl \
    dconf-cli \
    etckeeper \
    ffmpeg \
    firefox \
    git \
    gnupg2 \
    htop \
    httpie \
    httrack \
    jq \
    language-pack-en \
    libssl-dev \
    ncdu \
    parallel \
    pass \
    pcscd \
    python \
    python-pip \
    python3 \
    python3-pip \
    scdaemon \
    sox \
    ssh \
    tig \
    tmpreaper \
    tmux \
    tree \
    upx \
    vim \
    wget \
    zsh \

adhoc_dstask_linux_amd64
adhoc_ripgrep_linux_amd64
adhoc_fzf_linux_amd64
adhoc_neovim_linux_amd64
adhoc_golang_linux_amd64

# ykman only available in later versions of ubuntu. Install if available.
sudo apt-get -y install yubikey-manager || true

# ykman only available in later versions of ubuntu. Install if available.
sudo apt-get -y install yubikey-manager || true

adhoc_alacritty_linux_amd64
adhoc_browserpass_linux_amd64
adhoc_openscad_linux_amd64
