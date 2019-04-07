sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
sudo hwclock --systohc
echo 'en_GB.UTF-8 UTF-8' | sudo tee /etc/locale.gen
sudo locale-gen

sudo cp system-configuration/etc/sshd_config /etc/ssh/
# validate config against openssh version before loading
/usr/sbin/sshd -t -f /etc/ssh/sshd_config
sudo systemctl restart sshd

# TODO hostname, somehow. Maybe this is set by the installer script.

# TODO keyboard layout in console
# TODO keyboard layout in X
# TODO keyboard layout in wayland


# TODO possibly elsewhere: fstab gen
# TODO possibly elsewhere: systemd-boot install + config
