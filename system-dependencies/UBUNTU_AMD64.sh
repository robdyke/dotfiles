# tmpreaper tries to do a post-install "configuration" screen to warn the user.
export DEBIAN_FRONTEND=noninteractive

# -E is necessary for DEBIAN_FRONTEND
sudo -E apt-get -y update
sudo -E apt-get install -y software-properties-common
sudo -E apt-add-repository --yes multiverse
sudo -E apt-get -y update
sudo -E apt-get -y upgrade

# CLI only
sudo -E apt-get -y install --install-recommends \
    bash-completion \
    curl \
    dconf-cli \
    entr \
    ffmpeg \
    gimp \
    git \
    git-crypt \
    gnupg2 \
    htop \
    httpie \
    httrack \
    jq \
    language-pack-en \
    libsox-fmt-mp3 \
    libssl-dev \
    ncdu \
    parallel \
    pass \
    pcscd \
    picocom \
    python \
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
    vlc \
    wget \
    zsh \

# prevent typos from causing slowdowns
sudo -E apt-get -y remove command-not-found

# new in 20.04, might not exist if older ubuntu is targeted
sudo -E apt-get -y install zfsutils-linux || true
sudo -E apt-get -y install wireguard || true

adhoc_dstask_linux_amd64
adhoc_ripgrep_linux_amd64
adhoc_fzf_linux_amd64
adhoc_neovim_linux_amd64
adhoc_golang_linux_amd64
adhoc_hugo_linux_amd64
adhoc_ffsend_linux_amd64

# GUI if applicable
if [ -d /usr/share/xsessions ] && [ ! -z "$(ls /usr/share/xsessions/)" ]; then
    sudo -E apt-get -y update
    sudo apt-get -y install firefox powertop kicad

    # only available in later versions of ubuntu. Install if available.
    sudo apt-get -y install yubikey-manager || true
    sudo apt-get -y install kicad || true

    adhoc_alacritty_linux_amd64
    adhoc_browserpass_linux_amd64
    adhoc_openscad_linux_amd64
    adhoc_cura_linux_amd64
fi
