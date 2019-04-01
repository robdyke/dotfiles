#!/bin/bash
sudo -E ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# apply temporarily, as above requires restart (I think)
test $DISPLAY && setxkbmap -option "caps:escape" gb || true
