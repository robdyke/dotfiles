#!/bin/bash
set -ex
source include/util.sh
assert_root()

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# apply temporarily, as above requires restart (I think)
test $DISPLAY && setxkbmap -option "caps:escape" gb || true
