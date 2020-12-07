# ad-hoc installs for when programs are not packaged or out of date.
# checksummed to prevent forward supply channel attack

function adhoc_dstask_linux_amd64 {
    EXE="$(
        obtain \
            https://github.com/naggie/dstask/releases/download/v0.23.1/dstask-linux-amd64 \
            3e5a645b738682f276159ea1e198d5fae0a898011372b820df126d6b815b7642
    )"
    sudo cp "${EXE}" /usr/local/bin/dstask.new
    sudo chmod +x /usr/local/bin/dstask.new
    sudo mv -f /usr/local/bin/{dstask.new,dstask}
}

function adhoc_dstask_macos_amd64 {
    EXE="$(
        obtain \
            https://github.com/naggie/dstask/releases/download/v0.23.1/dstask-darwin-amd64 \
            d8c907f239bc324fdc5ae43528f3afe91b05e7118da681ff8155532aefe8f255
    )"
    cp "${EXE}" /usr/local/bin/dstask.new
    chmod +x /usr/local/bin/dstask.new
    mv -f /usr/local/bin/{dstask.new,dstask}
}

function adhoc_ripgrep_linux_amd64 {
    TARGZ="$(
        obtain \
            https://github.com/BurntSushi/ripgrep/releases/download/12.1.0/ripgrep-12.1.0-x86_64-unknown-linux-musl.tar.gz \
            c6bba6d643b1a1f18994683e26d4d2b998b41a7a7360e63cb8ec9db8ffbf793c
    )"
    [ -f /usr/local/bin/rg ] && sudo rm -f /usr/local/bin/rg
    sudo tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" ripgrep-12.1.0-x86_64-unknown-linux-musl/rg
}

function adhoc_fzf_linux_amd64 {
    TARGZ="$(
        obtain \
            https://github.com/junegunn/fzf/releases/download/0.24.4/fzf-0.24.4-linux_amd64.tar.gz \
            4bba748783f1b94d1635b265f69af60670cf0d717247f5c85a5c03948102619c
    )"
    [ -f /usr/local/bin/fzf ] && sudo rm -f /usr/local/bin/fzf
    sudo tar -C /usr/local/bin -xzf "$TARGZ"
}

function adhoc_neovim_linux_amd64 {
    # don't write directly, swap atomically so running nvim won't block)
    EXE="$(
        obtain \
            https://github.com/neovim/neovim/releases/download/v0.3.3/nvim.appimage \
            6c937c0a2b37e4ad99bae2f37f461ae47a590e62bddecf903b0b5bafe0eaaadb
    )"
    sudo cp "${EXE}" /usr/local/bin/nvim.new
    sudo chmod +x /usr/local/bin/nvim.new
    sudo mv -f /usr/local/bin/{nvim.new,nvim}
}

function adhoc_golang_linux_amd64 {
    TARGZ="$(
        obtain \
            https://dl.google.com/go/go1.13.linux-amd64.tar.gz \
            68a2297eb099d1a76097905a2ce334e3155004ec08cdea85f24527be3c48e856
    )"
    sudo tar -C /usr/local -xzf "$TARGZ"
}

function adhoc_alacritty_linux_amd64 {
    TARGZ="$(
        obtain \
            https://github.com/jwilm/alacritty/releases/download/v0.3.3/Alacritty-v0.3.3-ubuntu_18_04_amd64.tar.gz \
            b60856ef0d8861762465090501596b6d2cfeba34a6335ef6b718be878a39c0c0
    )"
    [ -f /usr/local/bin/alacritty ] && sudo rm -f /usr/local/bin/alacritty
    sudo tar -C /usr/local/bin/ -xzf "$TARGZ"
}

function adhoc_browserpass_linux_amd64 {
    TARGZ="$(
        obtain \
            https://github.com/browserpass/browserpass-native/releases/download/3.0.6/browserpass-linux64-3.0.6.tar.gz \
            f63047cbde5611c629b9b8e2acf6e8732dd4d9d64eba102c2cf2a3bb612b3360
    )"
    [ -f /usr/local/bin/browserpass ] && sudo rm -f /usr/local/bin/browserpass
    sudo tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" browserpass-linux64-3.0.6/browserpass-linux64
    sudo mv /usr/local/bin/browserpass-linux64 /usr/local/bin/browserpass
}

function adhoc_openscad_linux_amd64 {
    EXE="$(
        obtain \
            https://files.openscad.org/snapshots/OpenSCAD-2019.11.20.ai3988-eedfcc4-x86_64.AppImage \
            2f5cfe1224708bdb8c5e434876564b4767a48731c201a86655ec35b76dbe5426
    )"
    sudo cp "${EXE}" /usr/local/bin/openscad.new
    sudo chmod +x /usr/local/bin/openscad.new
    sudo mv -f /usr/local/bin/{openscad.new,openscad}
}

function adhoc_browserpass_macos_amd64 {
    TARGZ="$(
        obtain \
            https://github.com/browserpass/browserpass-native/releases/download/3.0.6/browserpass-darwin64-3.0.6.tar.gz \
            422bc6dd1270a877af6ac7801a75b4c4b57171d675c071470f31bc24196701e3
    )"
    [ -f /usr/local/bin/browserpass ] && sudo rm -f /usr/local/bin/browserpass
    sudo tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" browserpass-darwin64-3.0.6/browserpass-darwin64
    sudo mv /usr/local/bin/browserpass-darwin64 /usr/local/bin/browserpass
}

function adhoc_ripgrep_linux_armv5 {
    TARGZ="$(
        obtain \
            https://github.com/BurntSushi/ripgrep/releases/download/12.1.0/ripgrep-12.1.0-arm-unknown-linux-gnueabihf.tar.gz \
            9be3763d0215ad06fd6e0f6603c8b2680c9d7be5024811b82ae17d1ed823df70
    )"
    [ -f /usr/local/bin/rg ] && sudo rm -f /usr/local/bin/rg
    sudo tar -C /usr/local/bin/ --strip=1 -xzf "$TARGZ" ripgrep-12.1.0-arm-unknown-linux-gnueabihf/rg
}

function adhoc_fzf_linux_armv5 {
    TARGZ="$(
        obtain \
            https://github.com/junegunn/fzf/releases/download/0.24.4/fzf-0.24.4-linux_armv5.tar.gz \
            a9b723556bb71b26c5a121b9bd1636a4380af958cb170cd3acbe41e91597ab51
    )"
    [ -f /usr/local/bin/fzf ] && sudo rm -f /usr/local/bin/fzf
    sudo tar -C /usr/local/bin/ -xzf "$TARGZ"
}

function adhoc_cura_linux_amd64 {
    EXE="$(
        obtain \
            https://github.com/Ultimaker/Cura/releases/download/4.7.0/Ultimaker_Cura-4.7.0.AppImage \
            209ba51d11c65d115454ad128104c8de3369ef340cfb9102afa866f93a9ffa42
    )"
    sudo cp "${EXE}" /usr/local/bin/cura.new
    sudo chmod +x /usr/local/bin/cura.new
    sudo mv -f /usr/local/bin/{cura.new,cura}
}

function adhoc_hugo_linux_amd64 {
    TARGZ="$(
        obtain \
            https://github.com/gohugoio/hugo/releases/download/v0.69.2/hugo_0.69.2_Linux-64bit.tar.gz \
            167d8fb2db1728c0b24914030bab498e38d8ae1dcb01f792672b8a0085903ddf
    )"
    [ -f /usr/local/bin/hugo ] && sudo rm -f /usr/local/bin/hugo
    sudo tar -C /usr/local/bin/ -xzf "$TARGZ" hugo
}

function adhoc_ffsend_linux_amd64 {
    EXE="$(
        obtain \
            https://github.com/timvisee/ffsend/releases/download/v0.2.58/ffsend-v0.2.58-linux-x64-static \
            fb7c918b583197be3e553af5931816a885c1934a0adc16f2f03dfeed21b8ec0e
    )"
    sudo cp "${EXE}" /usr/local/bin/ffsend.new
    sudo chmod +x /usr/local/bin/ffsend.new
    sudo mv -f /usr/local/bin/{ffsend.new,ffsend}
}

