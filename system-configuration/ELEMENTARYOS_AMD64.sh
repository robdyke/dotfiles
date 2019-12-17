sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# replace ssh config if password authentication is enabled (on by default)
if ! sudo grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config; then
    sudo cp system-configuration/etc/sshd_config /etc/ssh/
    sudo systemctl restart sshd
fi

# browserpass config
sudo mkdir -p /usr/lib/mozilla/native-messaging-hosts/
sudo cp etc/firefox/com.github.browserpass.native.json /usr/lib/mozilla/native-messaging-hosts/

sudo etckeeper init
