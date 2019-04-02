#!/bin/bash
set -ex
source include/util.sh
assert_root()

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# set keyboard layout (with caps lock as esc)
cat <<- EOF > /etc/default/keyboard
    XKBMODEL="pc104"
    XKBLAYOUT="gb"
    XKBVARIANT=""
    XKBOPTIONS="caps:escape"
    BACKSPACE="guess"
EOF

# apply temporarily, as above requires restart (I think)
test $DISPLAY && setxkbmap -option "caps:escape" gb || true
