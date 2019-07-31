sudo timedatectl set-timezone Europe/London

sudo cp system-configuration/etc/sshd_config /etc/ssh/
sudo systemctl restart sshd

# TODO caps lock as esc

localectl set-keymap gb

# browserpass config
sudo mkdir -p /usr/lib/mozilla/native-messaging-hosts/
sudo cp etc/firefox/com.github.browserpass.native.json /usr/lib/mozilla/native-messaging-hosts/

sudo etckeeper init
