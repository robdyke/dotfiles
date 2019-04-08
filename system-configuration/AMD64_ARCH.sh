sudo ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
sudo hwclock --systohc
echo 'en_GB.UTF-8 UTF-8' | sudo tee /etc/locale.gen
sudo locale-gen

sudo cp system-configuration/etc/sshd_config /etc/ssh/
# validate config against openssh version before loading
/usr/sbin/sshd -t -f /etc/ssh/sshd_config
sudo systemctl restart sshd

# TODO keyboard layout in X
# TODO keyboard layout in wayland
# TODO map caps lock to esc on all above

# TODO keyboard repeat rates in all (super fast)


# keyboard layout in console
# TODO replace with custom keymap
# https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration
echo 'KEYMAP=uk' | sudo tee /etc/vconsole.conf
