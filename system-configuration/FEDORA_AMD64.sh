sudo timedatectl set-timezone Europe/London

# replace ssh config if password authentication is enabled (on by default)
if ! sudo grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config; then
    sudo cp system-configuration/etc/sshd_config /etc/ssh/
    sudo systemctl restart sshd
fi

sudo systemctl enable sshd
sudo systemctl restart sshd

# TODO caps lock as esc

localectl set-keymap gb

# browserpass config
sudo mkdir -p /usr/lib64/mozilla/native-messaging-hosts/
sudo cp etc/firefox/com.github.browserpass.native.json /usr/lib64/mozilla/native-messaging-hosts/
