sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

sudo cp system-configuration/etc/sshd_config /etc/ssh/
sudo systemctl restart sshd

# set keyboard layout (with caps lock as esc)
cat <<-EOF | sudo tee /etc/default/keyboard
    XKBMODEL="pc104"
    XKBLAYOUT="gb"
    XKBVARIANT=""
    XKBOPTIONS="caps:escape"
    BACKSPACE="guess"
EOF

# apply temporarily, as above requires restart (I think)
test $DISPLAY && setxkbmap -option "caps:escape" gb || true

# browserpass config
sudo mkdir -p /usr/lib/mozilla/native-messaging-hosts/
sudo cp etc/firefox/com.github.browserpass.native.json /usr/lib/mozilla/native-messaging-hosts/

sudo etckeeper init
