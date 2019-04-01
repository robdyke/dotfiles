CACHE_DIR=~/.cache/dotfiles

# download file if it doesn't exist, then check the sha256sum matches to
# mitigate forward-looking supply chain attacks. Exit script on fail.
function download_to_cache_dir {
    URL="$1"
    SHA256SUM="$2"

    FILENAME="$(echo $URL | rev | cut -d / -f 1 | rev)"
    TARGET="${CACHE_DIR}/${FILENAME}"

    mkdir -p "${CACHE_DIR}"

    if [ ! -f "$TARGET" ] || ! sha256sum $TARGET | grep -q $SHA256SUM; then
        curl -L "$URL" > "$TARGET"
    fi

    if ! sha256sum $TARGET | grep -q $SHA256SUM; then
        >&2 echo "Corrupt or compromised download detected! See $TARGET"
        exit 4
    fi

    echo "${TARGET}"
}
