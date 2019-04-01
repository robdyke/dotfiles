CACHE_DIR=~/.cache/dotfiles/

# download file if it doesn't exist, then check the sha256sum matches to
# mitigate forward-looking supply chain attacks. Exit script on fail.
function download_to_cache_dir {
    URL="$1"
    SHA256SUM="$2"
    TARGET="${CACHE_DIR}/${SHA256SUM}.bin"

    mkdir -p "${CACHE_DIR}"

    # download if does not exist or corrupt
    if [ ! -f $TARGET ] || ! sha256sum $TARGET | grep -q $SHA256SUM; then
        # file may be read only, should be (over)writable
        [ -f $TARGET ] && chmod 0600 $TARGET
        curl -L "$URL" > $TARGET
    fi

    if ! sha256sum $TARGET | grep -q $SHA256SUM; then
        >&2 echo "Corrupt or compromised download detected! See $TARGET ostensibly from $URL"
        exit 4
    fi

    # you will have to copy it and set correct permissions.
    chmod 0444 $TARGET

    echo $TARGET
}
