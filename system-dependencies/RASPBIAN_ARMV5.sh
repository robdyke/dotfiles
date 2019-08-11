# tmpreaper tries to do a post-install "configuration" screen to warn the user.
export DEBIAN_FRONTEND=noninteractive

# ripgrep
TARGZ="$(
    obtain \
        https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-arm-unknown-linux-gnueabihf.tar.gz \
        5909eb4246f8e4936a2d09d0b38c647733578f78f6aa5ace49027c1b7c4bf0e1
)"
[ -f /usr/local/bin/rg ] && sudo rm -f /usr/local/bin/rg
sudo tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" ripgrep-0.10.0-arm-unknown-linux-gnueabihf/rg

# FZF
TARGZ="$(
    obtain \
        https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_arm5.tgz \
        aa5f46c21fb765a20494fdcb00b86b6bde3b29538f25d49398f3b423f8e1e394
)"
[ -f /usr/local/bin/fzf ] && sudo rm -f /usr/local/bin/fzf
sudo tar -C /usr/local/bin/ -xzf "$TARGZ"

sudo apt-get -y update
sudo apt-get -y upgrade
# -E is necessary for DEBIAN_FRONTEND
sudo -E apt-get -y install \
    bash-completion \
    curl \
    etckeeper \
    git \
    gnupg2 \
    htop \
    httpie \
    jq \
    ncdu \
    pass \
    ssh \
    tig \
    tmpreaper \
    tmux \
    tree \
    vim \
    wget \
    zsh \
