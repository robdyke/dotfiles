# where to install bare EXEs (or softare compile from src)
BIN_DIR=/usr/local/bin
CACHE_DIR=~/.cache/dotfiles
mkdir -p $CACHE_DIR
# for local installs -- scripts, added to PATH with env.sh
mkdir -p ~/.local/bin
mkdir -p ~/.local/src

# download file if it doesn't exist, then check the sha256sum matches to
# mitigate forward-looking supply chain attacks. Exit script on fail.
function download_to_cache_dir {
    URL="$1"
    SHA256SUM="$2"

    FILENAME="$(echo $URL | rev | cut -d / -f 1 | rev)"
    TARGET="${CACHE_DIR}/${FILENAME}"

    if [ ! -f "$TARGET" ] || ! sha256sum $TARGET | grep -q $SHA256SUM; then
        curl -L "$URL" > "$TARGET"
    fi

    if ! sha256sum $TARGET | grep -q $SHA256SUM; then
        echo "Corrupt or compromised download detected! See $TARGET"
        exit 4
    fi
}
