sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# replace ssh config if password authentication is enabled (on by default)
if ! sudo grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config; then
    sudo cp system-configuration/etc/sshd_config /etc/ssh/
    sudo systemctl restart sshd
fi

# browserpass config
sudo mkdir -p /usr/lib/mozilla/native-messaging-hosts/
sudo cp etc/firefox/com.github.browserpass.native.json /usr/lib/mozilla/native-messaging-hosts/

# workaround for long running bug where system always suspends regardless of settings
# obviously not good for a laptop, but at the moment I have elementary on a desktop only.
# See https://elementaryos.stackexchange.com/questions/16519/elementary-os-ignoring-suspend-disable
# https://github.com/elementary/switchboard-plug-power/issues/122
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
